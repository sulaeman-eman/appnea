class CreateInstructors < ActiveRecord::Migration[8.1]
  def change
    create_table :instructors do |t|
      # Nullable: an instructor profile can exist on the site before (or without)
      # that person ever having a login.
      t.references :user, null: true, foreign_key: true, index: { unique: true }
      t.string :name, null: false
      t.text :bio, null: false, default: ""
      t.string :certifications, array: true, null: false, default: []
      t.integer :display_order, null: false, default: 0

      t.timestamps
    end

    add_index :instructors, :display_order
  end
end
