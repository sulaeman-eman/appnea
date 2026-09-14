class AddSearchVectorToCoursesAndArticles < ActiveRecord::Migration[8.1]
  def change
    # Stored generated columns keep the vector in step with the row without a
    # callback or a trigger to forget. 'english' gives stemming, so "courses"
    # matches "course"; the weights make a title hit outrank a body hit.
    add_column :courses, :searchable, :virtual,
      type: :tsvector,
      as: <<~SQL.squish,
        setweight(to_tsvector('english'::regconfig, coalesce(title, '')), 'A') ||
        setweight(to_tsvector('english'::regconfig, coalesce(level, '')), 'B') ||
        setweight(to_tsvector('english'::regconfig, coalesce(summary, '')), 'B') ||
        setweight(to_tsvector('english'::regconfig, coalesce(description, '')), 'C')
      SQL
      stored: true

    add_column :articles, :searchable, :virtual,
      type: :tsvector,
      as: <<~SQL.squish,
        setweight(to_tsvector('english'::regconfig, coalesce(title, '')), 'A') ||
        setweight(to_tsvector('english'::regconfig, coalesce(category, '')), 'B') ||
        setweight(to_tsvector('english'::regconfig, coalesce(excerpt, '')), 'B') ||
        setweight(to_tsvector('english'::regconfig, coalesce(body, '')), 'C')
      SQL
      stored: true

    add_index :courses, :searchable, using: :gin
    add_index :articles, :searchable, using: :gin
  end
end
