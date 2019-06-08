class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.references  :book,		null: false
      t.references  :user,		null: false
      t.boolean     :type,    default: true

      t.timestamps
    end
  end
end
