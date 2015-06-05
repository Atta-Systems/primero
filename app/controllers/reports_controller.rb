class ReportsController < ApplicationController

  include RecordFilteringPagination
  include ReportsHelper
  include DeleteAction

  #include RecordActions
  before_filter :sanitize_multiselects, only: [:create, :update]
  before_filter :sanitize_filters, only: [:create, :update]
  before_filter :set_aggregate_order, only: [:create, :update]

  def index
    authorize! :index, Report
    # NOTE: If we start needing anything more complicated than module filtering on reports,
    #       index them in Solr and make searchable. Replace all these views and paginations with Sunspot.
    report_ids = Report.by_module_id(keys: current_user.modules.map{|m|m.id}).values.uniq
    @current_modules = nil #TODO: Hack because this is expected in templates used.
    reports = Report.all(keys: report_ids).page(page).per(per_page).all
    @total_records = report_ids.count
    @per = per_page
    @reports = paginated_collection(reports, report_ids.count)
  end

  def show
    @report = Report.get(params[:id])
    authorize! :show, @report
    begin
      @report.build_report
    rescue Sunspot::UnrecognizedFieldError => e
      redirect_to(edit_report_path(@report), notice: e.message)
    end
  end

  # Method for AJAX GET of graph data.
  # This is returned in a format readable by Chart.js.
  # NOTE: We will need to change this if the Charting library changes
  # TODO: This is a seemingly redundant call to rebuild the report data for presentation on for the chart.
  #       For now I don't want to solve this problem: Report generation is relatively fast and relatively infrequent.
  #       The proper solution would be to load the report data once as an AJAX call and then massage on the
  #       client side for representation on the table and the chart. Or we culd get funky with caching generated reports,
  #       but really this isn't worth it unless we find that this is a performance bottleneck.
  def graph_data
    @report = Report.get(params[:id])
    authorize! :show, @report
    @report.build_report #TODO: Get rid of this once the rebuild works
    render json: @report.graph_data
  end

  def new
    authorize! :create, Report
    @report = Report.new
    @report.add_default_filters = true
    set_reportable_fields
  end

  def create
    authorize! :create, Report
    @report = Report.new(params[:report])
    return redirect_to report_path(@report) if @report.save
    set_reportable_fields
    render :new
  end

  def edit
    @report = Report.get(params[:id])
    authorize! :update, @report
    set_reportable_fields
  end

  def update
    @report = Report.get(params[:id])
    authorize! :update, @report

    if @report.update_attributes(params[:report])
      flash[:notice] = t("report.successfully_updated")
      redirect_to(report_path(@report))
    else
      set_reportable_fields
      flash[:error] = t("report.error_in_updating")
      render :action => "edit"
    end
  end

  def permitted_field_list
    authorize! :read, Report
    module_ids = (params[:module_ids].present? && params[:module_ids]!='null') ? params[:module_ids] : []
    modules = PrimeroModule.all(keys: module_ids).all
    record_type = params[:record_type]
    permitted_fields = select_options_fields_grouped_by_form(
      Report.all_reportable_fields_by_form(modules, record_type, @current_user),
      true
    ).each{|filter| filter.last.compact }.delete_if{|filter| filter.last.empty?}
    render json: permitted_fields
  end

  #This method returns a list of lookups for a particular field.
  #TODO: This really belongs in a fields or form section controller
  def lookups_for_field
    authorize! :read, Report
    field_options = []
    field_name = params[:field_name]
    field = Field.find_by_name(field_name)
    field_options = lookups_list_from_field(field)
    render json: field_options
  end

  # Method to trigger a report rebuild.
  # TODO: Currently this isn't used as we are not storing the generated report data.
  #       See models/report.rb and graph_data method above.
  def rebuild
    @report = Report.get(params[:id])
    authorize! :show, @report
    @report.build_report
    @report.save
    render status: :accepted
  end

  protected

  def set_aggregate_order
    params['report']['aggregate_by'] = params['report']['aggregate_by_ordered']
    params['report']['disaggregate_by'] = params['report']['disaggregate_by_ordered']
  end

  #TODO: This is a hack to get rid of empty values that sneak in due to this Rails select Gotcha:
  #      http://api.rubyonrails.org/classes/ActionView/Helpers/FormOptionsHelper.html#method-i-select
  #      We are trying to handle it in assets/javascripts/chosen.js and this is probably the best way to deal on refactor,
  #      but currently I don't want to sneeze on any card houses.
  def sanitize_multiselects
    [:module_ids, :aggregate_by, :disaggregate_by].each do |multiselect|
      if params[:report][multiselect].is_a? Array
        params[:report][multiselect].reject!{|e|!e.present?}
      else
        params[:report][multiselect] = nil
      end
    end
  end

  def sanitize_filters
    if params[:report][:filters].present?
      if params[:report][:filters][:template].present?
        params[:report][:filters].delete(:template)
        #convert to array: bad!
        filters = params[:report][:filters].values
        filters.each{|filter| filter.compact }.delete_if{|filter| filter.empty?}
        params[:report][:filters] = filters
      end
    end
  end

  def set_reportable_fields
    @reportable_fields ||= Report.all_reportable_fields_by_form(@report.modules, @report.record_type, @current_user)
    #TODO: There is probably a better way to deal with this than using hashes. Fix! Simplify the JS as well!
    @field_type_map = {}
    @reportable_fields.values.each do |module_properties|
      module_properties.each do |form_properties|
        form_properties[1].each do |property|
          @field_type_map[property[0]] = property[2]
        end
      end
    end
  end

  private

  def action_class
    Report
  end

end
