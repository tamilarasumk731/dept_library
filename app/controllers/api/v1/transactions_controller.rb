module Api
  module V1
    class TransactionsController < BaseController
      before_action :set_current_user, :except => [:index]
      before_action :requires_login, :except => [:index]
      before_action :check_role_for_authorization, :except => [:specific_issued_list, :specific_returned_list]
      before_action :all_role_authorization, :only => [:issued_list, :returned_list]
      before_action :set_staff, :except => [:return_book]
      before_action :set_book, :only => [:issue_book, :return_book]
      before_action :check_transaction, :only => [:issue_book]
   
      def issue_book
        @transaction = Transaction.new(user_id: @staff.id, book_id: @book.id)
        if book_status && @transaction.save
          @book.update(availability: "Issued")
          render json: {success: true, message: "Book issued successfully"}, status: :ok and return
        else
          render json: {success: false, message: user.errors.full_messages.to_sentence}, status: :ok and return
        end
      end

      def return_book
        @transaction = Transaction.where(book_id: @book.id, status: true)[0]
        @book.update(availability: "Available")
        if @transaction.present?
          @transaction.update(status: false)
          render json: {success: true, message: "Book returned successfully"}, status: :ok and return
        else
          render json: {success: false, message: "Transaction not found"}, status: :ok and return
        end
      end

      def specific_issued_list
        sql = "SELECT  books.access_no, books.book_name, transactions.created_at FROM books INNER JOIN transactions ON books.id = transactions.book_id WHERE transactions.user_id = #{@staff.id} AND transactions.status = true"
        books = ActiveRecord::Base.connection.execute(sql).to_a
        books.each do |h|
          h.store('due_date',h.delete('created_at'))
          h["due_date"] = (h["due_date"].to_date + 180.day).to_s
        end
        render json: {success: true, count: books.count, books: books}, status: :ok and return
      end

      def specific_returned_list
        sql = "SELECT  books.access_no, books.book_name, transactions.created_at FROM books INNER JOIN transactions ON books.id = transactions.book_id WHERE transactions.user_id = #{@staff.id} AND transactions.status = false"
        books = ActiveRecord::Base.connection.execute(sql).to_a
        books.each do |h|
          h.store('due_date',h.delete('created_at'))
          h["due_date"] = (h["due_date"].to_date + 180.day).to_s
        end
        render json: {success: true, count: books.count, books: books}, status: :ok and return
      end

      def issued_list

        sql = "SELECT  books.access_no, books.book_name, transactions.created_at FROM books INNER JOIN transactions ON books.id = transactions.book_id WHERE transactions.status = true"
        books = ActiveRecord::Base.connection.execute(sql).to_a
        books.each do |h|
          h.store('due_date',h.delete('created_at'))
          h["due_date"] = (h["due_date"].to_date + 180.day).to_s
        end
        render json: {success: true, count: books.count, books: books}, status: :ok and return
      end

      def returned_list
        sql = "SELECT  books.access_no, books.book_name, transactions.created_at FROM books INNER JOIN transactions ON books.id = transactions.book_id WHERE transactions.status = false"
        books = ActiveRecord::Base.connection.execute(sql).to_a
        books.each do |h|
          h.store('due_date',h.delete('created_at'))
          h["due_date"] = (h["due_date"].to_date + 180.day).to_s
        end
        render json: {success: true, count: books.count, books: books}, status: :ok and return
      end
    

      private

      def set_staff
        staff_id = params[:staff_id] || @current_user.staff_id
        @staff = User.find_by(staff_id: staff_id)
        if @staff == nil
          render json: {success: false, message: "Staff not found"}, status: :ok and return
        end
      end

      def set_book
        @book = Book.find_by(access_no: params[:access_no])
        if @book == nil
          render json: {success: false, message: "Book not found"}, status: :ok and return
        end
      end

      def check_transaction
        @transaction = Transaction.where(book_id: @book.id)[-1]
        if @transaction && @transaction.status == true
          render json: {success: false, message: "Book already borrowed by #{@transaction.user.name}"}, status: :ok and return
        end
      end

      def book_status
        if @book.availability == "Available"
          return true
        else
          render json: {success: false, message: "Book with Access_no #{@book.access_no} is #{@book.availability}"}, status: :ok and return
        end
      end

    end
  end
end