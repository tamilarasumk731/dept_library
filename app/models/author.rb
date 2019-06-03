class Author < ApplicationRecord
	has_many :book_authors
  has_many :books, through: :book_authors, dependent: :destroy

  validates :author_name,  presence: true
  validates :book_count,  presence: true


  def self.search_existing_authors_list author_records
  	author_ids = []
  	author_data = author_records[:author_name]
  	author_data.each do |author_name|
	  	update_or_add_author author_name, author_ids
	  end
	  author_ids
  end

  def self.update_or_add_author author_name, author_ids
  	author = Author.find_by(author_name: author_name)
  	if author.present?
  		update_book_count author, author_ids
  	else
  		add_a_new_author author_name, author_ids
  	end
	end

  def self.update_book_count author, author_ids
  	author.update(book_count: author[:book_count] + 1)
  	author_ids << author[:id]
  end

  def self.add_a_new_author author_name, author_ids
  	author_params = {:author_name => author_name, :book_count => 1}
  	author = Author.new(author_params)
  	if author.save
  		author_ids << author[:id]
  	else
  		render json: {success: false, message: author.errors.full_messages.to_sentence}
  	end
  end

  def self.rollback_author author_records
  	author_data = author_records[:author_name]
  	author_data.each do |author_name|
	  	update_author_table_to_previous_state author_name
	  end
  end

  def self.update_author_table_to_previous_state author_name
  	author = Author.find_by(author_name: author_name)
  	update_author_with_respect_to_book author
  end

  def self.update_author_with_respect_to_book author
  	if author[:book_count] == 1
  		author.destroy
  	else
  		author.update(book_count: author[:book_count] - 1)
  	end
  end

end
