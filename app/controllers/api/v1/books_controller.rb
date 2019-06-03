module Api
  module V1
    class BooksController < BaseController

      before_action :requires_login, :except => [:index]

      def create
        if @current_user.role == "Librarian"
          create_new_record
        else
          render json: {success: false, message: "Unauthorized access"}, status: :ok and return
        end
      end

      def search
        books = Book.where('lower(book_name) LIKE ?', "%#{search_params[:book_name].downcase}%")
        if books.present?
          render json: {success: true, message: "Books Matched: #{books.count}", count: books.count, books: books} and return
        else
          render json: {success: false, message: "Book Name not Found"} and return
        end
      end

      def create_new_record 
        @book = Book.new(book_params)
        unless author_params[:author_name].present?
          render json: {success: false, message: "Author for the Book is Empty"} and return
        end
        author_ids = lookup_author
        if  @book.save
          BookAuthor.update_book_author_list @book[:id], author_ids
          render json:{ success: true, message: "Book Added successful"}, status: :ok and return
        else
          Author.rollback_author author_params
          render json: {success: false, message: @book.errors.full_messages.to_sentence} and return
        end
      end
      
      def index
        @book = Book.all
        render json:{ success: true, message: "Books Available: #{@book.count}", count: @book.count, books: @book}, status: :ok and return
      end

      def lookup_author
        author_ids = Author.search_existing_authors_list author_params
        return author_ids
      end

      private

      def book_params
        params.require(:book).permit(:assess_no, :isbn, :book_name, :availability, :cupboard_no, :shelf_no, :price)
      end

      def author_params
        params.require(:book).permit(author_name:[])
      end

      def search_params
        params.require(:book).permit(:book_name)
      end
    end
  end
end