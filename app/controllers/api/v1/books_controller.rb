module Api
  module V1
    class BooksController < BaseController
      before_action :set_current_user, :except => [:index]
      before_action :requires_login, :except => [:index]

      def create
        if @current_user.role == "Librarian"
          create_new_record
        else
          render json: {success: false, message: "Unauthorized access"}, status: :ok and return
        end
      end

      def search
        if @current_user.status == "Approved"
          @page = params[:page] || 1
          @books = Book.where('lower(book_name) LIKE ?', "%#{search_params[:book_name].downcase}%").page(@page).per(20)
          render json: {success: false, message: "Book Name not Found"} and return if !@books.present?
        end
      end

      def update
        
      end

      def delete
        if @current_user.role == "Librarian"
          @book = Book.find_by(access_no: delete_params[:access_no])
          if @book.present?
            delete_author_record @book[:id]
            @book.destroy
            render json: {success: true, message: "Deleted Book: Access_no - #{@book[:access_no]}, Name - #{@book[:book_name]}", book: @book} and return
          else
            render json: {success: false, message: "Access no: #{delete_params[:access_no]} not Found"}, status: :not_found and return
          end
        else
          render json: {success: false, message: "Unauthorized access"}, status: :ok and return
        end
      end
      
      def index
        @page = params[:page] || 1
        @books = Book.all.page(@page).per(20)
      end

      private

      def delete_author_record book_id
        author_ids = BookAuthor.where(book_id: book_id)
        author_ids.each do |author_id| 
          author = Author.find(author_id[:author_id])
          Author.update_author_with_respect_to_book author 
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

      def lookup_author
        author_ids = Author.search_existing_authors_list author_params
        return author_ids
      end

      def book_params
        params.require(:book).permit(:access_no, :isbn, :book_name, :availability, :cupboard_no, :shelf_no, :price)
      end

      def author_params
        params.require(:book).permit(author_name:[])
      end

      def search_params
        params.require(:book).permit(:book_name)
      end

      def delete_params
        params.require(:book).permit(:access_no)
      end
    end
  end
end