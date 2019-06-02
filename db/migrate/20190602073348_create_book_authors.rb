class CreateBookAuthors < ActiveRecord::Migration[5.2]
  def change
    create_table :book_authors do |t|
    	t.references :book,		null:false
    	t.references :author,	null:false
      t.timestamps
    end
  end
end
