class ChangeColumnNameInBook < ActiveRecord::Migration[5.2]
  def up
    rename_column :books, :assess_no, :access_no
    change_column :books, :isbn, :string, null: false, length: 13
  end

  def down
    rename_column :books, :access_no, :assess_no
    change_column :books, :isbn, :string, null: false
  end
end
