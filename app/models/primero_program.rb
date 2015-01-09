class PrimeroProgram < CouchRest::Model::Base

  use_database :primero_program

  include PrimeroModel
  include Namable #delivers "name" and "description" fields

  property :start_date, Date
  property :end_date, Date


end
