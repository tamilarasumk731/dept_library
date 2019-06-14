class Book < ApplicationRecord
	enum availability: {'Ordered' => 0, 'Available' => 1, 'Issued' => 2, 'Damaged' => 3, 'Withdrawn' => 4, 'Requested' => 5, 'Lost' => 6}
  # enum shelf_no: {'A' => 1, 'B' => 2, 'C' => 3, 'D' => 4, 'E' => 5}

  has_many :book_authors
  has_many :authors, through: :book_authors
  has_many  :transactions
  has_many  :users, through: :transactions

  validates :access_no,  presence: true, uniqueness: true
  validates :book_name,  presence: true
  validates :availability,  presence: true
  validates :cupboard_no,  presence: true
  validates :shelf_no,  presence: true
  validates :price,  presence: true

  def self.check_for_valid_params actual_book, book_params
    status = Book.new(book_params)
    if !status.valid?
      errors = status.errors.to_h
      if remove_accessno_unique_error_if_needed errors, actual_book, book_params
        errors.except(:access_no)
      else
        errors
      end
    end
  end

  def self.remove_accessno_unique_error_if_needed errors, actual_book, book_params
    if actual_book[:access_no] == book_params[:access_no] && errors[:access_no] == "has already been taken"
      true
    else
      false
    end
  end

end
