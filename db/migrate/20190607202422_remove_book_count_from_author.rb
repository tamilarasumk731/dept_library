class RemoveBookCountFromAuthor < ActiveRecord::Migration[5.2]
  def change
    remove_column :authors, :book_count, :string
  end
end
