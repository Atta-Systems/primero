module Matchable
  extend ActiveSupport::Concern

  LIKELY = 'likely'
  POSSIBLE = 'possible'

  module ClassMethods

    MATCH_MAP = {
      'nationality' => 'relation_nationality',
      'language' => 'relation_language',
      'religion' => 'relation_religion',
      'ethnicity' => 'relation_ethnicity',
      'sub_ethnicity_1' => 'relation_sub_ethnicity1',
      'sub_ethnicity_2' => 'relation_sub_ethnicity2',
      'relation_nationality' => 'nationality',
      'relation_language' => 'language',
      'relation_religion' => 'religion',
      'relation_ethnicity' => 'ethnicity',
      'relation_sub_ethnicity1' =>'sub_ethnicity_1',
      'relation_sub_ethnicity2' => 'sub_ethnicity_2'
    }

    MATCH_FIELDS = [
      {fields: ['name', 'name_other', 'name_nickname'], boost: 15},
      {fields: ['sex'], boost: 10},
      {fields: ['age'], boost: 10},
      {fields: ['date_of_birth'], boost: 5},
      {fields: ['relation_name', 'relation_nickname', 'relation_other_family' ], boost: 10},
      {fields: ['relation'], boost: 5},
      {fields: ['relation_age'], boost: 5},
      {fields: ['relation_date_of_birth'], boost: 5},
      {fields: ['nationality', 'relation_nationality'], boost: 3},
      {fields: ['language', 'relation_language'], boost: 3},
      {fields: ['religion', 'relation_religion'], boost: 3},
      {fields: ['ethnicity', 'relation_ethnicity']},
      {fields: ['sub_ethnicity_1', 'relation_sub_ethnicity1']},
      {fields: ['sub_ethnicity_2', 'relation_sub_ethnicity2']}
    ]

    NORMALIZED_THRESHOLD = 0.1
    LIKELIHOOD_THRESHOLD = 0.7

    def form_matchable_fields(match_fields = nil)
      form_match_fields(false, match_fields)
    end

    def subform_matchable_fields(match_fields = nil)
      form_match_fields(true, match_fields)
    end

    def matchable_fields
      form_matchable_fields.concat(subform_matchable_fields)
    end

    def find_match_records(match_criteria, match_class, child_id = nil, require_consent = true)
      pagination = {:page => 1, :per_page => 20}
      sort={:score => :desc}
      if match_criteria.blank?
        []
      else
        search = Sunspot.search(match_class) do
          any do
            form_match_fields = match_class.matchable_fields
            match_criteria.each do |key, value|
              fields = match_class.get_match_field(key.to_s)
              fields = fields.select {|f| match_field_exist?(f, form_match_fields)}
              fulltext(value.join(' '), :fields => fields) do
                minimum_match 1
              end
            end
          end
          with(:id, child_id) if child_id.present?
          with(:consent_for_tracing, true) if require_consent && match_class == Child
          sort.each { |sort_field, order| order_by(sort_field, order) }
          paginate pagination
        end
        results = {}
        search.hits.each { |hit| results[hit.result.id] = hit.score }
        results
      end
    end

    def phonetic_fields
      ['name', 'name_nickname', 'name_other', 'relation_name', 'relation_nickname']
    end

    def map_match_field(field_name)
      MATCH_MAP[field_name] || field_name
    end

    def get_match_field(field)
      match_field =  MATCH_FIELDS.select { |f| f[:fields].include?(field.to_s) }.first
      match_field.blank? ? [field.to_sym] : match_field[:fields].map(&:to_sym)
    end

    def get_field_boost(field)
      default_boost_value = 1
      boost_field = MATCH_FIELDS.select { |f| f[:fields].include?(field.to_s) }.first
      boost_field.blank? ? default_boost_value : boost_field[:boost]
    end

    def match_field_exist?(field, field_list)
      # field must be present in the match_class matchable_fields to perform fulltext search.
      field_list.include?(field.to_s)
    end

    def match_multi_value(field, match_request)
      (match_request[field.to_sym].is_a? Array) ? match_request[field.to_sym].join(' ') : match_request[field.to_sym]
    end

    def match_multi_criteria(field, match_request)
      cluster_field = field
      result = [match_multi_value(field, match_request)]
      if result.first.present?
        match_field = MATCH_FIELDS.select { |f| f[:fields].include?(field) }.first
        if match_field.present?
          result += match_field[:fields].select{|f| f != field}.map do |f|
            match_multi_value(f, match_request)
          end
          cluster_field = match_field[:fields].first
        end
      end
      return cluster_field, result.reject(&:blank?)
    end

    def phonetic_fields_exist?(field)
      phonetic_fields.include?(field.to_s)
    end

    def form_match_fields(is_subform, match_fields)
      fields =  MatchingConfiguration.matchable_fields(self.parent_form, is_subform).map(&:name)
      return fields if match_fields.blank?
      fields & match_fields.values.flatten.reject(&:blank?)
    end

    def normalize_search_result(search_result)
      records = []
      if search_result.present?
        scores = search_result.values
        max_score = scores.max
        normalized_search_result = search_result.map{|k,v| [k,v/max_score.to_f]}
        average_score = normalized_search_result.to_h.values.sum / scores.count
        thresholded_search_result = normalized_search_result.select{|k,v| v > NORMALIZED_THRESHOLD}
        thresholded_search_result.each do |id, score|
          records << yield(id, score, average_score)
        end
      end
      records
    end

    def calculate_likelihood(score, aggregate_average_score)
      (score - aggregate_average_score) > LIKELIHOOD_THRESHOLD ? LIKELY : POSSIBLE
    end
  end

  def match_criteria(match_request=nil, match_fields=nil)
    match_criteria = {}
    self.class.form_matchable_fields(match_fields).each do |field|
      match_field, match_value = self.class.match_multi_criteria(field, self)
      match_criteria[:"#{match_field}"] = match_value if match_value.present?
    end
    match_criteria.compact
  end

end