class HomeController < ApplicationController

  before_filter :load_system_settings, :only => [:index]

  def index
    @page_name = t("home.label")
    @user = User.find_by_user_name(current_user_name)
    @notifications = PasswordRecoveryRequest.to_display
    load_user_module_data

    load_cases_information if display_cases_dashboard?
    load_incidents_information if display_incidents_dashboard?
    load_manager_information if display_manager_dashboard?
    load_gbv_incidents_information if display_gbv_incidents_dashboard?
    load_admin_information if display_admin_dashboard?
  end

  private

  def search_flags(options={})
    managed_users = options[:is_manager] ? current_user.managed_user_names : current_user.user_name
    map_flags(Flag.search{
      with(options[:field]).between(options[:criteria]) if options[:field].present? && options[:criteria].present?
      with(:flag_flagged_by, options[:flagged_by]) if options[:flagged_by].present?
      without(:flag_flagged_by, options[:without_flagged_by]) if options[:without_flagged_by].present?
      with(:flag_record_type, options[:type])
      with(:flag_record_owner, managed_users)
      with(:flag_flagged_by_module, options[:modules]) if options[:is_manager].present?
      with(:flag_is_removed, false)
      order_by(:flag_created_at, :desc)
    }.hits)
  end

  def map_flags(flags)
    flags.map{ |flag|
      {
        record_id: flag.stored(:flag_record_id),
        message: flag.stored(:flag_message),
        flagged_by: flag.stored(:flag_flagged_by),
        record_owner: flag.stored(:flag_owner),
        date: flag.stored(:flag_date),
        created_at: flag.stored(:flag_created_at),
        system_generated_follow_up: flag.stored(:flag_system_generated_follow_up),
        short_id: flag.stored(:flag_record_short_id),
        record_type: flag.stored(:flag_record_type),
        name: flag.stored(:flag_child_name),
        hidden_name: flag.stored(:flag_hidden_name),
        date_of_first_report: flag.stored(:flag_date_of_first_report),
      }
    }
  end

  def build_manager_stats(queries)
    @aggregated_case_manager_stats = {
      worker_totals: {},
      manager_totals: {},
      referred_totals: {}
    }

    managed_users = current_user.managed_user_names

    queries[:totals_by_case_worker].facet(:associated_user_names).rows.each do |c|
      if managed_users.include? c.value
        @aggregated_case_manager_stats[:worker_totals][c.value] = {}
        @aggregated_case_manager_stats[:worker_totals][c.value][:total_cases] = c.count
      end
    end

    queries[:new_by_case_worker].facet(:associated_user_names).rows.each do |c|
      if managed_users.include? c.value
        @aggregated_case_manager_stats[:worker_totals][c.value][:new_cases] = c.count
      end
    end

    queries[:manager_totals].facet(:child_status).rows.each do |c|
      @aggregated_case_manager_stats[:manager_totals][c.value] = c.count
    end

    queries[:referred_total].facet(:assigned_user_names).rows.each do |c|
      if managed_users.include? c.value
        @aggregated_case_manager_stats[:referred_totals][c.value] = {}
        @aggregated_case_manager_stats[:referred_totals][c.value][:total_cases] = c.count
      end
    end

    queries[:referred_new].facet(:assigned_user_names).rows.each do |c|
      if managed_users.include? c.value
        @aggregated_case_manager_stats[:referred_totals][c.value][:new_cases] = c.count
      end
    end

    @aggregated_case_manager_stats[:risk_levels] = queries[:risk_level]

    # flags.select{|d| (Date.today..1.week.from_now.utc).cover?(d[:date])}
    #      .group_by{|g| g[:flagged_by]}
    #      .each do |g, fz|
    #         if @aggregated_case_worker_stats[g].present?
    #           @aggregated_case_worker_stats[g][:cases_this_week] = fz.count
    #         # else
    #         #   @aggregated_case_worker_stats[g] = {cases_this_week: f.count}
    #         end
    #       end
    #
    # flags.select{|d| (1.week.ago.utc..Date.today).cover?(d[:date])}
    #      .group_by{|g| g[:flagged_by]}
    #      .each do |g, fz|
    #         if @aggregated_case_worker_stats[g].present?
    #           @aggregated_case_worker_stats[g][:cases_overdue] = fz.count
    #         # else
    #         #   @aggregated_case_worker_stats[g] = {cases_overdue: f.count}}
    #         end
    #       end
    @aggregated_case_manager_stats
  end

  def display_cases_dashboard?
    @display_cases_dashboard ||= @record_types.include?("case")
  end

  def display_manager_dashboard?
    @display_manager_dashboard ||= current_user.is_manager?
  end

  def display_incidents_dashboard?
    @display_incidents_dashboard ||= @record_types.include?("incident") && @module_ids.include?(PrimeroModule::MRM)
  end

  def display_gbv_incidents_dashboard?
    @display_gbv_incidents_dashboard ||= @record_types.include?("incident") && @module_ids.include?(PrimeroModule::GBV)
  end

  def display_admin_dashboard?
    @display_admin_dashboard ||= current_user.is_admin?
  end

  def manager_case_query(query = {})
    module_ids = @module_ids
    results =  Child.search do
      with(:record_state, true)
      with(:associated_user_names, current_user.managed_user_names)
      with(:child_status, query[:status]) if query[:status].present?
      with(:not_edited_by_owner, true) if query[:new_records].present?
      facet(:assigned_user_names, zeros: true) if query[:referred].present?
      if module_ids.present?
        any_of do
          module_ids.each do |m|
            with(:module_id, m)
          end
        end
      end
      if query[:by_owner].present?
        facet :associated_user_names, limit: -1, zeros: true
        adjust_solr_params do |params|
          params['f.owned_by_s.facet.mincount'] = 0
        end
      end
      facet(:child_status, zeros: true) if query[:by_case_status].present?
      if query[:by_risk_level].present?
        facet(:risk_level, zeros: true) do
          row(:high) do
            with(:risk_level, 'High')
            with(:not_edited_by_owner, true)
          end
          row(:high_total) do
            with(:risk_level, 'High')
          end
          row(:medium) do
            with(:risk_level, 'Medium')
            with(:not_edited_by_owner, true)
          end
          row(:medium_total) do
            with(:risk_level, 'Medium')
          end
          row(:low) do
            with(:risk_level, 'Low')
            with(:not_edited_by_owner, true)
          end
          row(:low_total) do
            with(:risk_level, 'Low')
          end
        end
      end
      paginate page: 1, per_page: 0
    end
  end

  def load_manager_information
    # TODO: Will Open be translated?
    # module_ids = @module_ids
    # flags = search_flags({
    #   field: :flag_date,
    #   criteria: 1.week.ago.utc...1.week.from_now.utc,
    #   type: 'child',
    #   is_manager: true,
    #   modules: @module_ids
    # })
    queries = {
      totals_by_case_worker: manager_case_query({ by_owner: true, status: 'Open' }),
      new_by_case_worker: manager_case_query({ by_owner: true, status: 'Open', new_records: true }),
      risk_level: manager_case_query({ by_risk_level: true, status: 'Open' }),
      manager_totals: manager_case_query({ by_case_status: true}),
      referred_total: manager_case_query({ referred: true, status: 'Open' }),
      referred_new: manager_case_query({ referred: true, status: 'Open', new_records: true })
    }
    build_manager_stats(queries)
  end

  def load_user_module_data
    @modules = @current_user.modules
    @module_ids = @modules.map{|m| m.id}
    @record_types = @modules.map{|m| m.associated_record_types}.flatten.uniq
  end

  def load_system_settings
    @system_settings ||= SystemSettings.current
    if @system_settings.present? && @system_settings.reporting_location_config.present?
      @admin_level ||= @system_settings.reporting_location_config.admin_level || ReportingLocation::DEFAULT_ADMIN_LEVEL
      @reporting_location ||= @system_settings.reporting_location_config.field_key || ReportingLocation::DEFAULT_FIELD_KEY
      @reporting_location_label ||= @system_settings.reporting_location_config.label_key || ReportingLocation::DEFAULT_LABEL_KEY
    else
      @admin_level ||= ReportingLocation::DEFAULT_ADMIN_LEVEL
      @reporting_location ||= ReportingLocation::DEFAULT_FIELD_KEY
      @reporting_location_label ||= ReportingLocation::DEFAULT_LABEL_KEY
    end
  end

  def load_recent_activities
    Child.list_records({}, {:last_updated_at => :desc}, { page: 1, per_page: 20 }, current_user.managed_user_names)
  end

  def load_cases_information
    module_ids = @module_ids
    @stats = Child.search do
      # TODO: Check for valid
      with(:child_status, 'Open')
      with(:record_state, true)
      associated_users = with(:associated_user_names, current_user.user_name)
      referred = with(:assigned_user_names, current_user.user_name)
      if module_ids.present?
        any_of do
          module_ids.each do |m|
            with(:module_id, m)
          end
        end
      end
      facet(:risk_level, zeros: true, exclude: [referred]) do
        row(:high) do
          with(:risk_level, 'High')
          with(:not_edited_by_owner, true)
        end
        row(:high_total) do
          with(:risk_level, 'High')
        end
        row(:medium) do
          with(:risk_level, 'Medium')
          with(:not_edited_by_owner, true)
        end
        row(:medium_total) do
          with(:risk_level, 'Medium')
        end
        row(:low) do
          with(:risk_level, 'Low')
          with(:not_edited_by_owner, true)
        end
        row(:low_total) do
          with(:risk_level, 'Low')
        end
      end

      facet(:records, zeros: true, exclude: [referred]) do
        row(:new) do
          with(:not_edited_by_owner, true)
        end
        row(:total) do
          with(:child_status, 'Open')
        end
      end

      facet(:referred, zeros: true) do
        row(:new) do
          without(:last_updated_by, current_user.user_name)
        end
        row(:total) do
          with(:child_status, 'Open')
        end
      end
    end

    show_flagged_by
  end

  def show_flagged_by
    flag_criteria = {
        field: :flag_created_at,
        type: 'child',
        is_manager: current_user.is_manager?,
        modules: @module_ids
    }

    @flagged_by_me = search_flags(flag_criteria.merge({flagged_by: current_user.user_name}))
    @flagged_by_me = @flagged_by_me[0..9]

    if current_user.is_manager?
      # @recent_activities = load_recent_activities.results
      # @scheduled_activities = search_flags({field: :flag_date, criteria: Date.today..1.week.from_now.utc, type: 'child'})
    elsif
    @flagged_by_others = search_flags(flag_criteria.merge({without_flagged_by: current_user.user_name}))
      @flagged_by_others = @flagged_by_others[0..9]
    end
  end

  def load_incidents_information
    #Retrieve only MRM incidents.
    flag_criteria = {
        field: :flag_created_at,
        criteria: 1.week.ago.utc..Date.tomorrow,
        type: 'incident'
    }
    modules = [PrimeroModule::MRM]
    @incidents_recently_flagged = search_flags(flag_criteria)
    @incidents_recently_flagged = @incidents_recently_flagged[0..4]
    @open_incidents = Incident.open_incidents(@current_user)
  end

  def load_gbv_incidents_information
    @gbv_incidents_recently_flagged = search_flags({field: :flag_created_at, criteria: 1.week.ago.utc..Date.tomorrow,
                                                type: 'incident'})
    @gbv_incidents_recently_flagged = @gbv_incidents_recently_flagged[0..4]
    @open_gbv_incidents = Incident.open_gbv_incidents(@current_user)
  end

  def load_admin_information
    last_week = 1.week.ago.beginning_of_week .. 1.week.ago.end_of_week
    this_week = DateTime.now.beginning_of_week .. DateTime.now.end_of_week
    locations = current_user.managed_users.map{|u| u.location}.compact.reject(&:empty?)

    if locations.present?
      @reporting_location_stats = build_admin_stats({
        totals: get_admin_stat({ status: 'Open', locations: locations, by_reporting_location: true }),
        new_last_week: get_admin_stat({ status: 'Open', new: true, date_range: last_week, locations: locations, by_reporting_location: true }),
        new_this_week: get_admin_stat({ status: 'Open', new: true, date_range: this_week, locations: locations, by_reporting_location: true }),
        closed_last_week: get_admin_stat({ status: 'Closed', closed: true, date_range: last_week, locations: locations, by_reporting_location: true }),
        closed_this_week: get_admin_stat({ status: 'Closed', closed: true, date_range: this_week, locations: locations, by_reporting_location: true })
      })
    end

    @protection_concern_stats = build_admin_stats({
      totals: get_admin_stat({by_protection_concern: true }),
      open: get_admin_stat({ status: 'Open', by_protection_concern: true }),
      new_this_week: get_admin_stat({ status: 'Open', by_protection_concern: true, new: true, date_range: this_week}),
      closed_this_week: get_admin_stat({ status: 'Closed', by_protection_concern: true, closed: true, date_range: this_week})
    })
  end

  def build_admin_stats(stats)
    admin_stats = {}
    protection_concerns = Lookup.values('Protection Concerns', @lookups)
    stats.each do |k, v|
      stat_facet = v.facet("#{@reporting_location}#{@admin_level}".to_sym) || v.facet(:protection_concerns)
      stat_facet.rows.each do |l|
        admin_stats[l.value] = {} unless admin_stats[l.value].present?
        admin_stats[l.value][k] = l.count ||= 0
        if v.facet(:protection_concerns).present? && !protection_concerns.include?(l.value)
          admin_stats.delete(l.value)
        end
      end
    end
    admin_stats
  end

  def get_admin_stat(query)
    #This is necessary because the instance variables can't be seen within the search block below
    admin_level = @admin_level
    reporting_location = @reporting_location

    module_ids = @module_ids
    return Child.search do
      if module_ids.present?
        any_of do
          module_ids.each do |m|
            with(:module_id, m)
          end
        end
      end
      with(:associated_user_names, current_user.managed_user_names)
      with(:record_state, true)
      with(:child_status, query[:status]) if query[:status].present?
      with(:created_at, query[:date_range]) if query[:new].present?
      with(:date_closure, query[:date_range]) if query[:closed].present?
      facet("#{reporting_location}#{admin_level}".to_sym, zeros: true) if query[:by_reporting_location].present?
      facet(:protection_concerns, zeros: true) if query[:by_protection_concern].present?
    end
  end
end
