class RolesController < ApplicationController
  @model_class = Role

  include ExportActions
  include ImportActions

  def index
    authorize! :index, Role
    @page_name = t("roles.label")
    sort_option = params[:sort_by_descending_order] || false
    params[:show] ||= "All"
    @roles = params[:show] == "All" ? Role.by_name(:descending => sort_option) : Role.by_name(:descending => sort_option).find_all{|role| role.has_permission(params[:show])}

    respond_to do |format|
      format.html
      respond_to_export(format, @roles)
    end
  end

  def show
    @role = Role.get(params[:id])
    @forms_by_record_type = FormSection.all_forms_grouped_by_parent
    authorize! :view, @role

    respond_to do |format|
      format.html
      respond_to_export(format, [@role])
    end
  end

  def edit
    @role = Role.get(params[:id])
    @forms_by_record_type = FormSection.all_forms_grouped_by_parent
    authorize! :update, @role
  end

  def update
    @role = Role.get(params[:id])
    authorize! :update, @role

    if @role.update_attributes(params[:role])
      flash[:notice] = t("role.successfully_updated")
      redirect_to(roles_path)
    else
      flash[:error] = t("role.error_in_updating")
      @forms_by_record_type = FormSection.all_forms_grouped_by_parent
      render :action => "edit"
    end
  end

  def new
    authorize! :create, Role
    @role = Role.new
    @forms_by_record_type = FormSection.all_forms_grouped_by_parent
  end

  def create
    authorize! :create, Role
    @role = Role.new(params[:role])
    return redirect_to roles_path if @role.save
    @forms_by_record_type = FormSection.all_forms_grouped_by_parent
    render :new
  end

  def destroy
    @role = Role.get(params[:id])
    authorize! :destroy, @role
    @role.destroy
    redirect_to(roles_url)
  end

end
