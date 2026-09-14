module Searchable
  extend ActiveSupport::Concern

  included do
    # websearch_to_tsquery parses what people actually type — quoted phrases,
    # OR, leading minus — and never raises on malformed input, unlike
    # to_tsquery. Results come back ranked, best first.
    scope :search, ->(query) {
      cleaned = query.to_s.strip
      next none if cleaned.blank?

      tsquery = sanitize_sql_array([ "websearch_to_tsquery('english', ?)", cleaned ])

      where("searchable @@ #{tsquery}")
        .reorder(Arel.sql("ts_rank_cd(searchable, #{tsquery}) DESC"))
    }
  end
end
