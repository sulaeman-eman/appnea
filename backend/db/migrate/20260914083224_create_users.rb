class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :name, null: false
      # 0 guest, 1 student, 2 instructor, 3 admin — see User#role
      t.integer :role, null: false, default: 1

      t.timestamps
    end

    # Emails are stored downcased by the model, so a plain unique index is enough.
    add_index :users, :email, unique: true
  end
end
