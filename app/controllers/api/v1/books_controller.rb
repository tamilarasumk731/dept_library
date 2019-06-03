module Api
  module V1
    class BooksController < BaseController

      before_action :requires_login, :except => [:index]

      def create
        if @current_user.role == "Librarian"
          @book = Book.new(book_params)
          unless author_params[:author_name].present?
            render json: {success: false, message: "Author for the Book is Empty"} and return
          end
          author_ids = lookup_author(book_params)
          if  @book.save
            BookAuthor.update_book_author_list @book[:id], author_ids
            render json:{ success: true, message: "Book Added successful"}, status: :ok and return
          else
            render json: {success: false, message: @book.errors.full_messages.to_sentence} and return
          end
        else
          render json: {success: false, message: "Unauthorized access"} and return
        end
      end
      
      def index
        @book = Book.all
        render json:{ success: true, message: @book}, status: :ok and return
      end

      def lookup_author(book_params)
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
    end
  end
end