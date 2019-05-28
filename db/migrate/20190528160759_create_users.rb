class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string  :name,             null: false, length: 50
      t.integer :staff_id,         null: false
      t.string  :email,            null: false, length: 50
      t.integer :role,             null: false, length: 4, default: 0
      t.integer :desig,            null: false, length: 6, default: 0
      t.string  :password_digest,  null: false, length: 128
      t.integer :status,           null: false, length: 4, default: 0
      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :name
    add_index :users, :staff_id, unique: true
  end
end
