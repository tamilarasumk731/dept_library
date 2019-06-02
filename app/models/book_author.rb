class BookAuthor< ApplicationRecord
	belongs_to :book
  belongs_to :author

  def self.update_book_author_list book_id, author_ids
  	author_ids.each{ |author_id| update_record(book_id, author_id) }
  end

  def self.update_record(book_id, author_id)
  	book_author = BookAuthor.find_by(book_id: book_id, author_id: author_id)
  	unless book_author.present?
  		new_book_author_record book_id, author_id
  	end
  end

  def self.new_book_author_record book_id, author_id
  	book_author_params = {:book_id => book_id, :author_id => author_id}
  	book_author = BookAuthor.new(book_author_params)
  	unless book_author.save
  		render json: {success: false, message: author.errors.full_messages.to_sentence}
  	end
  end
end
