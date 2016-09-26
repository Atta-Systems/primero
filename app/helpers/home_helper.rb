module HomeHelper

  def link_dashboard_title(record)
    model = model_name(record)
    send("#{model}_link_dashboard_title", record)
  end

  def link_dashboard_path(record)
    model = model_name(record)
    send("#{model}_path", id: record[:record_id] || record)
  end

  def index_link_dashboard_path(model)
    model = model_name_class(model).pluralize
    send("#{model}_path") + "?scope[flag]=single||flag"
  end

  def case_count(stat_group, query, model)
    if query.present?
      results = query.facet(stat_group[:name]).rows
      total = results.select{|v| v.value == stat_group[:stat]}.first.count
    else
      total = stat_group[:count]
    end
    total = 0 if !total.present?
    link = stat_link(total, stat_group, model)
    return { count: total, stat: link, stat_type: stat_group[:stat_type], case_worker: stat_group[:case_worker] }
  end

  def stat_link(total, stat_group, model)
    if total == 0
      return content_tag(:div, total, class: 'stat_link')
    else
      model = model_name_class(model).pluralize
      filter = stat_group[:filter] || ''
      return link_to(total, send("#{model}_path") + filter, class: 'stat_link')
    end
  end

  def build_reporting_location_stat_link(stat, filters=nil, model, reporting_location, admin_level)
    if stat == 0
      return stat
    else
      model = model_name_class(model).pluralize
      return link_to(stat, send("#{model}_path") + index_filters(filters, reporting_location, admin_level), class: 'stat_link')
    end
  end

  def index_filters(filters, reporting_location='owned_by_location', admin_level=2)
    list = []
    index_filters_list = {
      child_status: "scope[child_status]=list||",
      new: "scope[last_updated_by]=neg||#{current_user.user_name}",
      referred_users: "scope[referred_users]=list||#{current_user.user_name}",
      referred_user: "scope[referred_users]=list||",
      risk_level: "scope[risk_level]=list||",
      record_state: "scope[record_state]=list||",
      location: "scope[location_current]=location||",
      reporting_location: "scope[#{reporting_location}#{admin_level}]=list||",
      created_at: "scope[created_at]=date_range||",
      date_closure: "scope[date_closure]=date_range||",
      owned_by: "scope[owned_by]=list||",
      new_owned_by: "scope[last_updated_by]=neg||",
      new_other: "scope[not_edited_by_owner]=single||true",
      user: "scope[associated_user_names]=list||",
      protection_concern: "scope[protection_concerns]=list||",
      approval_status_bia: "scope[approval_status_bia]=list||",
      approval_status_case_plan: "scope[approval_status_case_plan]=list||",
      approval_status_closure: "scope[approval_status_closure]=list||",
      transfer_status: "scope[transfer_status]=list||"
    }
    filters.each do |filter|
      filter = filter.split('=')
      if filter.size > 1
        list << index_filters_list[filter.first.to_sym] + filter.last
      elsif
        list << index_filters_list[filter.first.to_sym]
      end
    end
    return "?" + list.join('&')
  end

  def last_week
    return "#{1.week.ago.beginning_of_week.strftime("%d-%b-%Y")}.#{1.week.ago.end_of_week.strftime("%d-%b-%Y")}"
  end

  def this_week
    return "#{DateTime.now.beginning_of_week.strftime("%d-%b-%Y")}.#{DateTime.now.end_of_week.strftime("%d-%b-%Y")}"
  end

  private

  def case_link_dashboard_title(child)
    child_name = child[:hidden_name] ? '*****' : child[:name]
    text = [child[:short_id], child_name, field_format_date(child[:created_at])]
    "#{text.compact.join(" - ")}"
  end

  def incident_link_dashboard_title(incident)
    text = [incident[:short_id], field_format_date(incident[:date])]
    "#{text.compact.join(" - ")}"
  end

  def model_name(record)
    model = record[:record_type].present? ? record[:record_type] : record.class.name.underscore
    model = "case" if model == "child"
    model
  end

  def model_name_class(model_class)
    model = model_class.name.underscore
    model = "case" if model == "child"
    model
  end

end
