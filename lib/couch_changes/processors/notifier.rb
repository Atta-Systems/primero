module CouchChanges
  module Processors
    # Notifies the individual Passenger processes.  This notifier uses a simple
    # delay based batching system in which it waits two seconds after the first
    # notification to notify the server, including whatever changes have come
    # in the preceding two seconds in the notification.  It will then repeat
    # that process two seconds after the next change is received.
    class Notifier < BaseProcessor
      @delay_timer = nil

      class << self
        def supported_models
          [Lookup, Location, FormSection, User, Agency, PrimeroModule, Role, SystemSettings, ConfigurationBundle]
        end

        DELAY_SECONDS = 2

        def process(modelCls, change)
          dfd = EventMachine::DefaultDeferrable.new

          CouchChanges.logger.info "Queueing notification to Passenger instances about change \##{change['seq']} to #{modelCls.name}"

          start_timer_if_inactive
          add_change_to_queue(modelCls, change, dfd)

          dfd
        end

        def reset_delay_queue
          # TODO: confirm that this doesn't need a mutex! I don't think EM will
          # process events concurrently but that may be a bad assumption.
          @delay_queue = supported_models.inject({}) {|acc, m| acc.merge(m => []) }
        end

        def start_timer_if_inactive
          unless @delay_timer.present?
            CouchChanges.logger.info "Creating timer to notify server of changes in #{DELAY_SECONDS} seconds"
            @delay_timer = EM.add_timer(DELAY_SECONDS) do
                                initiate_notifications
                                @delay_timer = nil
                               end
          end
        end

        def add_change_to_queue(modelCls, change, dfd)
          reset_delay_queue if @delay_queue.nil?
          @delay_queue[modelCls] << {:change => change, :dfd => dfd}
        end

        def get_changed_models
          @delay_queue.select {|k, v| v.length > 0 }.keys
        end

        def pass_all_dfds
          each_dfd {|dfd| dfd.succeed }
          reset_delay_queue
        end

        def fail_all_dfds(msg=nil)
          each_dfd {|dfd| dfd.fail(msg) }
          reset_delay_queue
        end

        def each_dfd
          return enum_for(:each_dfd) unless block_given?

          @delay_queue.each do |m, arr|
            arr.each do |h|
              yield h[:dfd]
            end
          end
        end

        def initiate_notifications
          begin
            procs = CouchChanges::Passenger.http_process_info
          rescue PassengerNotRunningError => e
            CouchChanges.logger.warn "Marking notifier as done since Passenger isn't running"
            pass_all_dfds
          rescue MultiplePassengersError
            CouchChanges.logger.error "Cannot handle multiple Passenger servers!"
            fail_all_dfds "Multiple Passenger Servers"
          else
            notify_each_process(procs)
          end
        end

        def notify_each_process(procs)
          multi = EventMachine::MultiRequest.new

          procs.each {|p| start_request_to_process(p, get_changed_models, multi) }

          multi.callback do
            # For now, just mark the notification as successful if the
            # request didn't catastrophically fail, regardless of the status
            # code returned by rails.
            if multi.responses[:errback].length == 0
              CouchChanges.logger.info "App successfully notified of queued changes"# \##{change['seq']} on model #{modelCls.name}"
              pass_all_dfds
            else
              multi.responses[:errback].each do |k, v|
                CouchChanges.logger.error "Error notifying app instance #{k} of queued changes: #{v.try(:error)}"# \##{change['seq']} on model #{modelCls.name}: #{v.try(:error)}"
              end
              fail_all_dfds
            end
          end
        end

        def start_request_to_process(process, models_changed, multi)
          uri = Addressable::URI.parse(Rails.application.routes.url_for(:controller => 'couch_changes', :action => 'notify', :host => process.address))

          headers = {
            'X-Passenger-Connect-Password' => process.password,
            'Content-Type' => 'application/json'
          }
          uri.query_values = models_changed.map {|m| ['models_changed[]', m.name] }

          # Use GET here instead of POST since the requests hang on normal POST requests.  See
          # https://groups.google.com/forum/#!topic/phusion-passenger/-XYYtqTQpLk
          multi.add(process.pid, EventMachine::HttpRequest.new(uri.to_s).get(:head => headers))
        end
      end
    end
  end
end
