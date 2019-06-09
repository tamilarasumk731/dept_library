module Api
  module V1
    class TransactionsController < BaseController
      before_action :set_current_user, :except => [:index]
      before_action :requires_login, :except => [:index]
      before_action :check_role_for_authorization
      before_action :set_staff, 
      before_action :set_book, :except => [:issued_list, :returned_list]
      before_action :check_transaction, :only => [:issue_book]
   
      def issue_book
        @transaction = Transaction.new(user_id: @staff.id, book_id: @book.id)
        if @transaction.save
          render json: {success: true, message: "Book issued successfully"}, status: :ok and return
        else
          render json: {success: false, message: user.errors.full_messages.to_sentence}, status: :ok and return
        end
      end

      def return_book
        @transaction = Transaction.where(user_id: @staff.id, book_id: @book.id, status: true)[0]
        if @transaction.present?
          @transaction.update(status: false)
          render json: {success: true, message: "Book returned successfully"}, status: :ok and return
        else
          render json: {success: true, message: "Transaction not found"}, status: :ok and return
        end
      end

      def issued_list
        sql = "SELECT  books.access_no, books.book_name, transactions.created_at FROM books INNER JOIN transactions ON books.id = transactions.book_id WHERE transactions.user_id = #{@staff.id} AND transactions.status = true"
        books = ActiveRecord::Base.connection.execute(sql).to_a
        books.each do |h|
          h.store('due_date',h.delete('created_at'))
          h["due_date"] = (h["due_date"].to_date + 180.day).to_s
        end
        render json: {success: true, transaction: books}, status: :ok and return
      end

      def returned_list
        sql = "SELECT  books.access_no, books.book_name, transactions.created_at FROM books INNER JOIN transactions ON books.id = transactions.book_id WHERE transactions.user_id = #{@staff.id} AND transactions.status = false"
        books = ActiveRecord::Base.connection.execute(sql).to_a
        books.each do |h|
          h.store('due_date',h.delete('created_at'))
          h["due_date"] = (h["due_date"].to_date + 180.day).to_s
        end
        render json: {success: true, transaction: books}, status: :ok and return
      end

      def specific_issued_list
        sql = "SELECT  books.access_no, books.book_name, transactions.created_at FROM books INNER JOIN transactions ON books.id = transactions.book_id WHERE transactions.status = true"
        books = ActiveRecord::Base.connection.execute(sql).to_a
        books.each do |h|
          h.store('due_date',h.delete('created_at'))
          h["due_date"] = (h["due_date"].to_date + 180.day).to_s
        end
        render json: {success: true, transaction: books}, status: :ok and return
      end

      def specific_returned_list
        sql = "SELECT  books.access_no, books.book_name, transactions.created_at FROM books INNER JOIN transactions ON books.id = transactions.book_id WHERE transactions.status = false"
        books = ActiveRecord::Base.connection.execute(sql).to_a
        books.each do |h|
          h.store('due_date',h.delete('created_at'))
          h["due_date"] = (h["due_date"].to_date + 180.day).to_s
        end
        render json: {success: true, transaction: books}, status: :ok and return
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
        @book = Book.find_by(access_no: transaction_params[:access_no])
        if @book == nil
          render json: {success: false, message: "Book not found"}, status: :ok and return
        end
      end

      def check_transaction
        @transaction = Transaction.where(book_id: @book.id)[-1]
        if @transaction.status == true
          render json: {success: false, message: "Book already issued to #{@transaction.user.name}"}
        end
      end

      def transaction_params
        params.require(:transaction).permit(:staff_id, :access_no)
      end
    end
  end
end