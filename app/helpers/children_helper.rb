module ChildrenHelper

  module View
    PER_PAGE = 20
    MAX_PER_PAGE = 9999
  end

  module EditView
    ONETIME_PHOTOS_UPLOAD_LIMIT = 5
  end
  ORDER_BY = {'active' => 'created_at', 'all' => 'created_at', 'reunited' => 'reunited_at', 'flag' => 'flag_at'}

  def is_playable_in_browser audio
    AudioMimeTypes.browser_playable? audio.mime_type
  end

  def link_to_update_info(child)
    link_to('and others', child_history_path(child)) unless child.has_one_interviewer?
  end

  def flag_summary_for_child(child)
    flag_history = child["histories"].select{|h| h["changes"].keys.include?("flag") }.first
     "<b>"+ I18n.t("child.flagged_by")+" </b>"+ flag_history["user_name"] +"<b> "+I18n.t("preposition.on_label")+"</b> " + current_user.localize_date(flag_history["datetime"]) +"<b> "+I18n.t("preposition.because")+"</b> "+ child["flag_message"]
  end

  def reunited_message
    "Reunited"
  end

  def duplicate_message
    raw ("This record has been marked as a duplicate and is no longer active. To see the Active record click #{link_to 'here', child_path(@child.duplicate_of)}.")
  end

  def link_for_filter filter, selected_filter
    return filter.capitalize if filter == selected_filter
    link_to(filter.capitalize, child_filter_path(filter))
  end

  def link_for_order_by filter, order, order_id, selected_order
    return order_id.capitalize if order == selected_order
    link_to(order_id.capitalize, child_filter_path(:filter => filter, :order_by => order))
  end

  def text_to_identify_child(child)
    child.case_id_display.present? ? child.case_id_display : child.short_id
  end

  def case_workflow_status_text(child, lookups)
    workflow_text = Lookup.display_value('lookup-workflow', child.workflow_status, lookups)
    case child.workflow_status
    when Child::WORKFLOW_NEW
      "#{workflow_text} #{t("case.workflow.created_on")} #{I18n.l(child.created_at)}"
    when Child::WORKFLOW_CLOSED
      case_status_date_text(workflow_text, child.date_closure)
    when Child::WORKFLOW_REOPENED
      case_status_date_text(workflow_text, child.reopened_date)
    when Child::WORKFLOW_SERVICE_IMPLEMENTED
      "#{workflow_text}"
    else
      service_provision_text = Lookup.display_value('lookup-service-response-type', child.workflow_status, lookups)
      if service_provision_text.present?
        "#{service_provision_text} #{t("case.workflow.in_progress")}"
      else
        t("case.workflow.in_progress")
      end
    end
  end

  def case_status_date_text(text, a_date)
    if a_date.present? && (a_date.is_a?(Date) || a_date.is_a?(DateTime))
      "#{text} #{t("case.workflow.on_label")} #{I18n.l(a_date)}"
    else
      "#{text}"
    end
  end

  def toolbar_for_child child
    if child.duplicate?
      link_to 'View the change log', child_history_path(child)
    else
      render :partial => "show_child_toolbar"
    end
  end

  def select_box_default(model, field)
    if field == 'status'
      return Record::STATUS_OPEN
    else
      return (model[field] || '')
    end
  end

  def display_formated_section_error(error)
    content_tag :li, class: "error-item", data: { error_item: error[:internal_section] } do
      "<span>#{h(error[:translated_section])}:</span> #{h(error[:message])}".html_safe
    end
  end

  def create_step(desc, active=false, disabled=false)
    step_class = 'step'
    step_class += ' active' if active.present?
    step_class += ' disabled' if disabled.present?

    content_tag :div, class: step_class do
      content_tag :div, class: 'content' do
        content_tag :div, desc, class: 'description'
      end
    end
  end

  def build_steps(child, lookups, blacklisted=[], display_case_plan_in_stepper)
    closed_text = Lookup.display_value('lookup-case-status', Record::STATUS_CLOSED, lookups)
    service_response_types = Lookup.values_for_select('lookup-service-response-type', lookups)
    new_step =
      if child.case_status_reopened.present?
        [I18n.t("case.workflow.reopened"), Child::WORKFLOW_REOPENED]
      else
        [I18n.t("case.workflow.new"), Child::WORKFLOW_NEW]
      end

    steps = []
    steps << new_step
    steps << [I18n.t("case.workflow.case_plan"), Child::WORKFLOW_CASE_PLAN] if display_case_plan_in_stepper
    steps += service_response_types
    steps << [I18n.t("case.workflow.service_implemented"), 'services_implemented']
    steps << [closed_text, Record::STATUS_CLOSED]
    steps.reject{ |st|  blacklisted.include? st[1] }
  end

  def display_workflow_status(child, lookups, blacklisted=[], display_case_plan_in_stepper)
    steps = build_steps(child, lookups, blacklisted, display_case_plan_in_stepper)

    content_tag :div, class: 'ui mini steps' do
      disable = false

      steps.each do |step|
        active = child.workflow_status == step[1]
        concat(create_step(step[0], active, disable && !active))
        disable = true if active
      end
    end
  end

end
