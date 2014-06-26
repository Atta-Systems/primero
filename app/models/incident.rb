class Incident < CouchRest::Model::Base
  use_database :incident
  
  include RapidFTR::Model
  include RapidFTR::CouchRestRailsBackward
  
  include SearchableRecord
  
  property :incident_id
  property :description
  
  def initialize *args 
    self['histories'] = []
    super *args
  end
  
  design do
    view :by_incident_id
    view :by_description,
              :map => "function(doc) {
                  if (doc['couchrest-type'] == 'Incident')
                 {
                    if (!doc.hasOwnProperty('duplicate') || !doc['duplicate']) {
                      emit(doc['description'], doc);
                    }
                 }
              }"
  end
  
  def self.find_by_incident_id(incident_id)
    by_incident_id(:key => incident_id).first
  end
  
  def self.all 
    view('by_description', {})  
  end 
  
  def self.search_field
    "description"
  end
  
  def self.view_by_field_list
    ['created_at', 'description']
  end
  
  def createClassSpecificFields(fields)
    self['incident_id'] = self.incident_id
    self['description'] = fields['description'] || self.description || ''
  end

  def incident_id
    self['unique_identifier']
  end
end
