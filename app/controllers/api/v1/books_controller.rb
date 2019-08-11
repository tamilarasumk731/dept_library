module Api
  module V1
    class BooksController < BaseController
      include Api::V1::AuthorUtils

      before_action :set_current_user, :except => [:index, :batch_create]
      before_action :requires_login, :except => [:index, :batch_create]
      before_action :check_role_for_authorization, :except => [:index, :batch_create]
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
        book_update_params = book_params
        is_valid = Book.check_for_valid_params actual_book, book_params.to_h
        if is_valid.keys.blank?
          begin
            book_update_params = book_update_params.merge(authors: authors) if authors.present?
            book = actual_book.update(book_update_params)
            book_update_params[:authors] = book_update_params[:authors].map(&:author_name)
            render json: {success: true, message: "Book updated successfully", book: book_update_params} and return
          rescue => e
            render json: {success: false, message: e.message.split(': ')[1]}, status: :ok and return
          end
        else
          render json: {success: false, message: is_valid} and return
        end
      end

      def delete
        book = Book.find_by(access_no: book_params[:access_no])
        if book.present?
          book.authors.destroy_all
          book.destroy
          render json: {success: true, message: "Access No: #{book_params[:access_no]} removed successfully"}, status: :ok and return
        else
          render json: {success: false, message: "Access No: #{book_params[:access_no]} not Found"}, status: :ok and return
        end
      end
      
      def index
        # @page = params[:page] || 1
        @books = Book.all
      end

      def batch_create
        filename = "book_#{Time.now.getutc.strftime('%Y%m%dT%H%M%SZ')}"
        book_details = Array.new
        CSV.open("storage/book_files/#{filename}", "wb") do |csv|
          File.foreach(params["book"].tempfile) do |line|
            book_details << CSV.parse_line(line.chomp)
            csv << [line.chomp]
          end
        end
        begin
          parse_csv_file(book_details)
        rescue => e
          render json: {success: false, message: "Exception occured while processing bulk book upload - #{e.message}"} and return
        end
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

      def parse_csv_file(book_details)
        raise "No records to process" if book_details.count <= 1
        header_count = 0
        book_records = Array.new
        book_details.each_with_index do |row, i|
          if i == 0
            header_count = row.count
            next
          end
          if row.count != header_count
            render json: {success: false, message: "Skipping Update due to mismatch with the header #{key}"} and return
          end
          book_records << prepare_record(row)
          if book_records.size == 100
            status = Book.process_records book_records
            book_records = []
          end
        end
        status = Book.process_records book_records if book_records.present?
        if status == true
          render json: {success: true, message: "Books uploaded successfully"}, status: :ok and return
        else
          render json: {success: true, message: "Books upload failed"}, status: :ok and return
        end
      end

      def prepare_record(row)
        record = {:access_no => row[0],
                  :isbn => row[1],
                  :book_name => row[2],
                  :availability => "Available",
                  :cupboard_no => row[4].to_i,
                  :shelf_no => row[5].to_i,
                  :price => row[6].to_f,
                  :author => row[7],
                }
      end

      def type_cast_if_needed
        # params[:book][:availability] = params[:book][:availability].to_i
        params[:book][:cupboard_no] = params[:book][:cupboard_no].to_i
        params[:book][:shelf_no] = params[:book][:shelf_no].to_i
      end
    end
  end
end