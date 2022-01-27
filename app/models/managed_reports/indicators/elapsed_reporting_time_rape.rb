# frozen_string_literal: true

# An indicator that returns the total of incidents grouped by elapsed_reporting_time
# and where the gbv_sexual_violence_type is rape
class ManagedReports::Indicators::ElapsedReportingTimeRape < ManagedReports::SqlReportIndicator
  class << self
    def id
      'elapsed_reporting_time_rape'
    end

    def sql(params = [])
      %{
        select
          data->> 'elapsed_reporting_time' as id,
          count(*) as total
        from incidents
        where data->> 'elapsed_reporting_time' is not null
        and data ->> 'gbv_sexual_violence_type' = 'rape'
        #{filter_query(params)}
        group by data ->> 'elapsed_reporting_time'
      }
    end

    def build(args = {})
      super(args, &:to_a)
    end
  end
end