class Book < ApplicationRecord
  extend Api::V1::AuthorUtils
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

  def self.process_records book_records
    access_nos = []
    book_records.each{ |book| access_nos << book[:access_no]}
    existing_books = get_existing_books(access_nos)
    books_to_be_created = create_all_books book_records, existing_books
    if books_to_be_created.present?
      books_to_be_created.each do |valid_book|
        Book.create(valid_book.except(:author))
      end
      true
    else
      false
    end
  end

  def self.get_existing_books(all_access_nos)
    existing_access_nos = []
    existing_books = Book.where("access_no IN (:access_nos)", access_nos: all_access_nos)
    existing_books.each{ |book| existing_access_nos << book[:access_no]}
    existing_access_nos
  end

  def self.create_all_books book_records, existing_books
    books_to_be_created = []
    book_author_record = []
    book_records.each do |book_record|
      unless existing_books.include? book_record[:access_no]
        books_to_be_created = Book.new(book_record.except(:author))
        if books_to_be_created.valid?
          book_author_params = []
          book_author_params = books_with_authors({author_name: book_record[:author].split(/\//)})
          book_author_record << book_record.merge(authors: book_author_params.flatten)
        end
      end
    end
    book_author_record
  end

  def self.books_with_authors(author_name)
    if author_name.present?
      update_author_if_needed(author_name)
    end
  end

end
