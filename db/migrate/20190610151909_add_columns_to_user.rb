class AddColumnsToUser < ActiveRecord::Migration[5.2]
  def up
    add_column    :users, :intercom, :string, length: 10
    add_column    :users, :salutation, :integer, length: 4, default: 0
    change_column :books, :isbn, :string, null: true
  end

  def down
    remove_column :users, :intercom
    remove_column :users, :salutation
    change_column :books, :isbn, :string, null: false
  end
end
