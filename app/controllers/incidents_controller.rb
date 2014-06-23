class IncidentsController < ApplicationController
  include SearchingForRecords
  
  before_filter :set_class_name
  
  def index
    authorize! :index, Incident
    
    @incidents = Incident.all
  end
  
  
  def show
    @incident = Incident.get(params[:id])
    authorize! :read, @incident if @incident["created_by"] != current_user_name

    
    @form_sections = get_form_sections
  end
  
  def new
    authorize! :create, Incident
    
    @incident = Incident.new
    @form_sections = get_form_sections 
    respond_to do |format|
      format.html
      format.xml { render :xml => @incident }
    end   
  end
  
  def create
    authorize! :create, Incident
    params[:incident] = JSON.parse(params[:incident]) if params[:incident].is_a?(String)
    create_or_update_incident(params[:incident])
    @incident['created_by_full_name'] = current_user_full_name

    respond_to do |format|
      if @incident.save
        flash[:notice] = t('incident.messages.creation_success')
        format.html { redirect_to(incident_path(@incident, { follow: true })) }
        #format.xml { render :xml => @incident, :status => :created, :location => @child }
        format.json {
          render :json => @incident.compact.to_json
        }
      else
        format.html {
          @form_sections = get_form_sections

          # TODO: (Bug- https://quoinjira.atlassian.net/browse/PRIMERO-161) This render redirects to the /children url instead of /cases
          render :action => "new"
        }
        format.xml { render :xml => @incident.errors, :status => :unprocessable_entity }
      end
    end
  end
  

  
  private
  
  def get_form_sections
    FormSection.find_all_visible_by_parent_form(Incident.parent_form)
  end
  
  def incident_short_id incident_params
    incident_params[:short_id] || incident_params[:unique_identifier].last(7)
  end
  
  def create_or_update_incident(incident_params)
    @incident = Incident.by_short_id(:key => incident_short_id(incident_params)).first if incident_params[:unique_identifier]
    if @incident.nil?
      @incident = Incident.new_with_user_name(current_user, incident_params)
    else
      #@incident = update_incident_from(params)
    end
  end
  

  
  def respond_to_export(format, records)
    RapidftrAddon::ExportTask.active.each do |export_task|
      format.any(export_task.id) do
        #authorize! "export_#{export_task.id}".to_sym, Child
        #LogEntry.create! :type => LogEntry::TYPE[export_task.id], :user_name => current_user.user_name, :organisation => current_user.organisation, :child_ids => children.collect(&:id)
        #results = export_task.new.export(children)
        #encrypt_exported_files results, export_filename(children, export_task)
      end
    end
  end
  
  def set_class_name
    @className = Incident
  end
 
end