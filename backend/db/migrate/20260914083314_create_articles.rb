class CreateArticles < ActiveRecord::Migration[8.1]
  def change
    create_table :articles do |t|
      t.string :slug, null: false
      t.string :title, null: false
      t.text :excerpt, null: false, default: ""
      t.text :body, null: false, default: ""
      t.string :category, null: false, default: "general"
      # Nil means draft. Phase 2 scopes the public API to published_at <= now.
      t.datetime :published_at

      t.timestamps
    end

    add_index :articles, :slug, unique: true
    add_index :articles, :published_at
    add_index :articles, :category
  end
end
