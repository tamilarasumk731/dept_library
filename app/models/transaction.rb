class Transaction < ApplicationRecord
  
  # boolean status: {'Issued' => true, 'Returned' => false}
  
  belongs_to :book
  belongs_to :user

end
