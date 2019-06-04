class CreateBooks < ActiveRecord::Migration[5.2]
  def change
    create_table :books do |t|
      t.string :assess_no, 		null: false
      t.string :isbn, 			null: false
      t.string :book_name, 		null: false
      t.integer :availability,	null: false
      t.integer :cupboard_no,	null: false
      t.integer :shelf_no,		null: false
      t.float :price,			null: false
      t.timestamps
    end

    add_index :books, :assess_no, unique: true 
    add_index :books, :isbn
    add_index :books, :book_name
  end
end
