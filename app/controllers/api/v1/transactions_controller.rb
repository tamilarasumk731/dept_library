module Api
  module V1
    class TransactionsController < BaseController
      before_action :set_current_user, :except => [:index]
      before_action :requires_login, :except => [:index]
      before_action :check_role_for_authorization
      before_action :set_staff, :except => [:return]
      before_action :set_book, :except => [:borrowed_list, :returned_list]
      before_action :check_transaction, :only => [:borrow]
   
      def borrow
        @transaction = Transaction.new(user_id: @staff.id, book_id: @book.id)
        if @transaction.save
          render json: {success: true, message: "Book borrowed successfully"}, status: :ok and return
        else
          render json: {success: false, message: user.errors.full_messages.to_sentence}, status: :ok and return
        end
      end

      def return
        @transaction = Transaction.where(book_id: @book.id, status: true)[0]
        if @transaction.present?
          @transaction.update(status: false)
          render json: {success: true, message: "Book returned successfully"}, status: :ok and return
        else
          render json: {success: true, message: "Transaction not found"}, status: :ok and return
        end
      end

      def borrowed_list
        @page = params[:page] || 1
        book_ids = @staff.transactions.where(status: false).map(&:book_id).uniq
        @books = Book.where(id: book_ids).page(@page).per(20)
      end

      def returned_list
        @page = params[:page] || 1
        book_ids = @staff.transactions.where(status: true).map(&:book_id).uniq
        @books = Book.where(id: book_ids).page(@page).per(20)
      end
    

      private

      def set_staff
        staff_id = transaction_params[:staff_id] || params[:staff_id]
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
          render json: {success: false, message: "Book already borrowed by #{@transaction.user.name}"}
        end
      end

      def transaction_params
        params.require(:transaction).permit(:staff_id, :access_no)
      end
    end
  end
end