module Api
  module V1
    class BooksController < BaseController
      before_action :set_current_user, :except => [:index]
      before_action :requires_login, :except => [:index]
      before_action :check_role_for_authorization, :except => [:index]
      before_action :type_cast_if_needed, :only => [:create, :update]

      def create
        book = Book.new(book_params)
        if book.valid?
          authors = update_author_if_needed author_params
          create_new_record book_params, authors
        else
          render json: {success: false, message: book.errors.full_messages.to_sentence} and return
        end
      end

      def update_author_if_needed author_params
        if author_params.present? && author_params[:author_name].present?
          all_authors = Array.new
          author_params[:author_name].each do |author|
            all_authors << Author.find_or_create_by(author_name: author)
          end
          all_authors
        else
          render json: {success: false, message: "Author name should not be empty"} and return
        end
      end

      def create_new_record book_params, authors
        if authors.present?
          Book.create(book_params.merge(authors: authors))
          render json:{ success: true, message: "Book Added successful", book: book_params.merge(author_params)}, status: :ok and return
        else
          render json: {success: false, message: "Author is not created"} and return
        end
      end

      def search
        # @page = params[:page] || 1
        @books = Book.where('lower(book_name) LIKE ?', "%#{search_params[:book_name].downcase}%")
        render json: {success: false, message: "Book Name not Found"} and return if !@books.present?
      end

      def update
        book = Book.find_by(access_no: book_params[:access_no])
        if book.present?
          if author_params.present?
            authors = update_author_if_needed author_params
            update_book book, authors
          else  
            update_book book
          end
        else
          render json: {success: false, message: "Book is empty for the Access_no: #{book_params[:access_no]}"} and return
        end
      end

      def update_book actual_book, authors = []
        book_update_params = book_params.to_h
        is_valid = Book.check_for_valid_params actual_book, book_params.to_h
        if is_valid.keys.blank?
          begin
            book_update_params = book_update_params.merge(authors: authors) if authors.present?
            book = actual_book.update(book_update_params)
            render json: {success: true, message: "Book updated successfully", book: book_update_params} and return
          rescue => e
            render json: {success: false, message: e.message.split(': ')[1]}, status: :ok and return
          end
        else
          render json: {success: false, message: is_valid} and return
        end
      end

      def delete
        book = Book.find(book_params[:access_no])
        if book.present?
          book.authors.destroy_all
          book.destroy
          render json: {success: true, message: "Access No: #{book_params[:access_no]} removed successfully"}, status: :ok and return
        else
          render json: {success: false, message: "Access No: #{book_params[:access_no]} not Found"}, status: :not_found and return
        end
      end
      
      def index
        # @page = params[:page] || 1
        @books = Book.all
      end

      private

      def book_params
        params.require(:book).permit(:id, :access_no, :isbn, :book_name, :availability, :cupboard_no, :shelf_no, :price)
      end

      def author_params
        params.require(:book).permit(author_name:[])
      end

      def search_params
        params.require(:book).permit(:book_name)
      end

      def type_cast_if_needed
        params[:book][:availability] = params[:book][:availability].to_i
        params[:book][:cupboard_no] = params[:book][:cupboard_no].to_i
        params[:book][:shelf_no] = params[:book][:shelf_no].to_i
      end
    end
  end
end