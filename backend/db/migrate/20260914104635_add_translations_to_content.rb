class AddTranslationsToContent < ActiveRecord::Migration[8.1]
  def change
    # Per-locale overrides, shaped { "id" => { "title" => "...", ... } }.
    # A jsonb column rather than a title_id/summary_id column per field, so
    # adding a third language later is data, not a migration. Anything missing
    # falls back to the base column, so a half-translated row still renders.
    add_column :courses, :translations, :jsonb, null: false, default: {}
    add_column :trips, :translations, :jsonb, null: false, default: {}
    add_column :articles, :translations, :jsonb, null: false, default: {}
  end
end
