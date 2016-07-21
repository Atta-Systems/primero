class LocationsController < ApplicationController

  @model_class = Location

  include DisableActions

  before_filter :load_location, :only => [:edit, :update, :destroy]
  before_filter :load_records_according_to_disable_filter, :only => [:index, :new, :edit]
  before_filter :load_types, :only => [:new, :edit]
  before_filter :load_admin_level, :only => [:new, :edit]

  def index
    authorize! :index, Location
    @page_name = t("location.index")
  end

  def new
    authorize! :create, Location
    @page_name = t("location.create")
    @location = Location.new(params[:location])
  end

  def create
    authorize! :create, Location
    location = Location.new(params[:location])
    location.generate_hierarchy

    if (location.valid?)
      location.create
      flash[:notice] = t("location.messages.updated")
      redirect_to locations_path
    else
      @location = location
      load_all_locations
      load_types
      render :new
    end
  end

  def edit
    authorize! :update, Location
    @page_name = t("location.edit")
  end

  def update
    authorize! :update, Location
    @location.update_attributes params[:location]
    @location.update_hierarchy

    if @location.save
      redirect_to locations_path
    else
      load_location
      load_all_locations
      load_types
      render :edit
    end
  end

  def destroy
    authorize! :destroy, Location
    @location.destroy
    flash[:notice] = t("location.messages.deleted")
    redirect_to locations_path
  end


  private

  def load_location
    @location = Location.get params[:id] if params[:id]
  end

  def load_types
    @location_types = Location::BASE_TYPES
  end

  def load_admin_level
    @location.calculate_admin_level
  end

end
