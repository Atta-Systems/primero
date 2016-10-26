module Transitionable
  extend ActiveSupport::Concern
  include Sunspot::Rails::Searchable

  included do
    property :transfer_status, String
    property :transitions, [Transition], :default => []


    def add_transition(transition_type, to_user_local, to_user_remote, to_user_agency, to_user_local_status, notes,
                       is_remote, type_of_export, user_name, consent_overridden, service = "")
      transition = Transition.new(
                    :type => transition_type,
                    :to_user_local => to_user_local,
                    :to_user_remote => to_user_remote,
                    :to_user_agency => to_user_agency,
                    :to_user_local_status => to_user_local_status,
                    :transitioned_by => user_name,
                    :notes => notes,
                    :is_remote => is_remote,
                    :type_of_export => type_of_export,
                    :service => service,
                    :consent_overridden => consent_overridden,
                    :created_at => DateTime.now)
      self.transitions.unshift(transition)
      transition
    end

    def transitions_transfer_status(transfer_id, transfer_status, user, rejected_reason)
      if transfer_status == I18n.t("transfer.#{Transition::TO_USER_LOCAL_STATUS_ACCEPTED}", :locale => :en) ||
         transfer_status == I18n.t("transfer.#{Transition::TO_USER_LOCAL_STATUS_REJECTED}", :locale => :en)
        #Retrieve the transfer that user accept/reject.
        transfer = self.transfers.select{|t| t.id == transfer_id }.first
        if transfer.present?
          #Validate that the transitions is in progress and the user is related to.
          if transfer.is_transfer_in_progress? && transfer.is_assigned_to_user_local?(user.user_name)
            #Change Status according the action executed.
            transfer.to_user_local_status = transfer_status
            #When is a reject action, there could be a reason.
            if rejected_reason.present?
              transfer.rejected_reason = rejected_reason
            end
            #Update the top level transfer status.
            self.transfer_status = transfer_status
            #Either way Accept or Reject the current user should be removed from the associated users.
            #So, it will have no access to the record anymore.
            self.assigned_user_names = self.assigned_user_names.reject{|u| u == user.user_name}
            if transfer_status == I18n.t("transfer.#{Transition::TO_USER_LOCAL_STATUS_ACCEPTED}", :locale => :en)
              #In case the transfer is accepted the current user is the new owner of the record.
              self.previously_owned_by = self.owned_by
              self.owned_by = user.user_name
              self.owned_by_full_name = user.full_name
            end
            #let know the caller the record was changed.
            status_changed = :transition_transfer_status_updated
          else
            status_changed = :transition_not_valid_transfer
          end
        else
          status_changed = :transition_unknown_transfer
        end
      else
        status_changed = :transition_unknown_transfer_status
      end
      status_changed
    end

  end

  def referrals
    self.transitions.select{|t| t.type == 'referral'}
  end

  def transfers
    self.transitions.select{|t| t.type == 'transfer'}
  end

  def has_referrals
    self.referrals.present?
  end
  alias :has_referrals? :has_referrals

  def reject_old_transitions
    self.transitions = [self.transitions.first]
  end

  def latest_external_referral
    referral = []
    transitions = self.try(:transitions)
    if transitions.present?
      ext_referrals = transitions.select do |transition|
        transition.type == Transition::TYPE_REFERRAL && transition.is_remote
      end
      if ext_referrals.present?
        # Expected result is either one or zero element array
        referral = [ext_referrals.first]
      end
    end
    referral
  end

  def given_consent(type = Transition::TYPE_REFERRAL)
    if self.module_id == PrimeroModule::GBV
      consent_for_services == true
    elsif self.module_id == PrimeroModule::CP
      if type == Transition::TYPE_REFERRAL
        disclosure_other_orgs == true && consent_for_services == true
      else
        disclosure_other_orgs == true
      end
    end
  end

end
