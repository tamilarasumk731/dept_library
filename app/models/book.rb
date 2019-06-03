class Book < ApplicationRecord
	enum availability: {'Ordered' => 0, 'Available' => 1, 'Issued' => 2, 'Damaged' => 3, 'Withdrawn' => 4, 'Requested' => 1, 'Lost' => 2}
	has_many :book_authors
  has_many :authors, through: :book_authors 

  validates :assess_no,  presence: true, uniqueness: true
  validates :isbn,  presence: true
  validates :book_name,  presence: true
  validates :availability,  presence: true
  validates :cupboard_no,  presence: true
  validates :shelf_no,  presence: true
  validates :price,  presence: true
end
