class ChangeColumnInUser < ActiveRecord::Migration[5.2]
  def up
    change_column :users, :role, :integer, default:  3, null: false
  end

  def down
    change_column :users, :role, :integer, default:  0, null: false
  end
end
