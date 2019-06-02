class CreateAuthors < ActiveRecord::Migration[5.2]
  def change
    create_table :authors do |t|
      t.string :author_name,  null:false, length: 30
    	t.integer :book_count,  null:false
      t.timestamps
    end
    add_index :authors, :author_name
  end
end
