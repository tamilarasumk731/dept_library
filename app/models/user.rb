class User < ApplicationRecord

  has_many :transactions
  has_many :books, through: :transactions

  has_secure_password
  enum role: {'HoD' => 0, 'Librarian' => 1, 'Incharge' => 2, 'Staff' => 3}
  enum desig: {'Professor' => 0, 'Associate Professor' => 1, 'Assistant Professor' => 2, 'Teaching Fellow' => 3, 'Professional Assistant' => 4}
  enum status: {'Pending' => 0, 'Approved' => 1, 'Left' => 2}
  enum salutation: {'Dr' => 0, 'Mr' => 1, 'Ms' => 2, 'Mrs' => 3}

  validates :name,  presence: true, length: {maximum: 50}
  validates :intercom, length: {maximum: 10}
  validates :salutation, presence: true
  validates :email, presence: true, email: {mx_with_fallback: true}, length: {maximum:100,                      allow_blank: true},  uniqueness: {case_sensitive: false, allow_blank: true}
  validates :role,  presence: true
  validates :desig,  presence: true
  validates :staff_id,  presence: true, uniqueness: true
  validates :status, presence: true
  validates :password, length: {minimum: 8, allow_blank: true}, presence: true, allow_nil: true
  
end