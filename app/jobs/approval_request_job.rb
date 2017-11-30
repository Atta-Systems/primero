class ApprovalRequestJob < ActiveJob::Base
  queue_as :mailer

  def perform(user_id, manager_id, case_id, approval_type, host_url)
    NotificationMailer.manager_approval_request(user_id, manager_id, case_id, approval_type, host_url).deliver_later
  end
end