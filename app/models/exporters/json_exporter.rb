module Exporters
  class JSONExporter < BaseExporter
    class << self
      def id
        'json'
      end

      def excluded_properties
        ['crypted_password', 'salt']
      end
    end

    def export(models, properties, *args)
        props = JSONExporter.properties_to_export(properties)
        hashes = models.map {|m| convert_model_to_hash(m, props)}
        self.buffer.write(JSON.pretty_generate(hashes))
    end

    def convert_model_to_hash(model, properties)
      prop_names = properties.map {|p| p.name}
      JSON.parse(model.to_json).select do |k,v|
        prop_names.include? k
      end.tap do |h|
        h['model_type'] = model.class.name
        h['_id'] = model.id
        h
      end
    end

  end
end
