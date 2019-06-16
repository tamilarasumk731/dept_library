module Api
  module V1
    class AuthController < BaseController

      skip_before_action :requires_login
      skip_before_action :set_current_user, :except => [:reset_password, :authorize_token]

      def signup    
        user = User.new(auth_params)
        if  user.save
          render json:{ success: true, message: "Signup successful"}, status: :ok and return
        else
          render json: {success: false, message: user.errors.full_messages.to_sentence}, status: :ok and return
        end
      end

      def hod_login
        @user = User.find_by(staff_id: auth_params[:staff_id])
        if  @user && @user.authenticate(auth_params[:password]) && (@user.role == "HoD") && (@user.status == "Approved")
          @token = Token.encode(@user.id)
          @staff_count = User.count
          @book_count = Book.count
          @issued_book_count = issued_book_count
          @new_book_count = new_book_count
          # render json: {success: true, token: token, message: 'logged in successfully' }
        else
          render json: {success: false, message: 'authentication failed' }, status: :ok and return
        end
      end

      def librarian_login
        @user = User.find_by(staff_id: auth_params[:staff_id])
        if  @user && @user.authenticate(auth_params[:password]) && (@user.role == "Librarian") && (@user.status == "Approved")
          @token = Token.encode(@user.id)
          @staff_count = User.count
          @book_count = Book.count
          @issued_book_count = issued_book_count
          # render json: {success: true, token: token, message: 'logged in successfully' }
        else
          render json: {success: false, message: 'authentication failed' }, status: :ok and return
        end
      end

      def incharge_login
        @user = User.find_by(staff_id: auth_params[:staff_id])
        if @user && @user.authenticate(auth_params[:password]) && (@user.role == "Incharge") && (@user.status == "Approved")
          @token = Token.encode(@user.id)
          @book_count = Book.count
          @issued_book_count = issued_book_count
          # render json: {success: true, token: token, message: 'logged in successfully' }
        else
          render json: {success: false, message: 'authentication failed' }, status: :ok and return
        end
      end

      def staff_login
        @user = User.find_by(staff_id: auth_params[:staff_id])
        if  @user && @user.authenticate(auth_params[:password]) && (@user.status == "Approved")
          @token = Token.encode(@user.id)
          @borrowed_book_count = borrowed_book_count @user
          # render json: {success: true, token: token, message: 'logged in successfully' }
        else
          render json: {success: false, message: 'authentication failed' }, status: :ok and return
        end
      end

      def forgot_password
        user = User.find_by(staff_id: params[:staff_id])
        if  user && (user.status == "Approved")
          token = Token.encode(user.id)
          begin
            UserMailer.forgot_password(user, token).deliver_now!
            render json: {success: true, message: 'Reset link sent' }
          rescue => e
            render json: {success: false, message: e}, status: :ok and return
          end
        else
          render json: {success: false, message: 'Staff not found' }, status: :ok and return
        end
      end

      def reset_password
        begin
          @current_user.update(password: params[:password])
          render json: {success: true, message: "Password reset success."}
        rescue => e
          render json: {success: false, message: e.message.split(': ')[1]}, status: :ok and return
        end
      end

      def authorize_token
        render json: {success: true, message: "Valid Token", role: @current_user.role}, status: :ok  and return
      end

      private
      def auth_params
        params.require(:auth).permit(:staff_id, :name, :email, :desig, :password, :salutation, :intercom)
      end

      def issued_book_count
        Transaction.where(status: "Approved").count
      end

      def new_book_count
        Book.where.not(id: Transaction.all.map(&:book_id).uniq).count
      end

      def borrowed_book_count user
        Transaction.where(user_id: user.id).count
      end

    end
  end
end
