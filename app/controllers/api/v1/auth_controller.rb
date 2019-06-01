module Api
  module V1
    class AuthController < BaseController

      skip_before_action :requires_login

      def signup    
        user = User.new(auth_params)
        user.status = "Approved"
        if  user.save
          render json:{ success: true, message: "Signup successful"}, status: :ok and return
        else
          render json: {success: false, message: user.errors.full_messages.to_sentence}
        end
      end

      def hod_login
        user = User.find_by(staff_id: auth_params[:staff_id])
        if  user && user.authenticate(auth_params[:password]) && (user.role == "HoD") && (user.status == "Approved")
          token = Token.encode(user.id)
          render json: {success: true, token: token, message: 'logged in successfully' }
        else
          render json: {success: false, message: 'authentication failed' }, status: :bad_request and return
        end
      end

      def librarian_login
        user = User.find_by(staff_id: auth_params[:staff_id])
        if  user && user.authenticate(auth_params[:password]) && (user.role == "Librarian") && (user.status == "Approved")
          token = Token.encode(user.id)
          render json: {success: true, token: token, message: 'logged in successfully' }
        else
          render json: {success: false, message: 'authentication failed' }, status: :bad_request and return
        end
      end

      def incharge_login
        user = User.find_by(staff_id: auth_params[:staff_id])
        if  user && user.authenticate(auth_params[:password]) && (user.role == "Incharge") && (user.status == "Approved")
          token = Token.encode(user.id)
          render json: {success: true, token: token, message: 'logged in successfully' }
        else
          render json: {success: false, message: 'authentication failed' }, status: :bad_request and return
        end
      end

      def staff_login
        user = User.find_by(staff_id: auth_params[:staff_id])
        if  user && user.authenticate(auth_params[:password]) && (user.role == "HoD" || user.role == "Staff") && (user.status == "Approved")
          token = Token.encode(user.id)
          render json: {success: true, token: token, message: 'logged in successfully' }
        else
          render json: {success: false, message: 'authentication failed' }, status: :bad_request and return
        end
      end

      private
      def auth_params
        params.require(:auth).permit(:staff_id, :name, :email, :desig, :password)
      end

    end
  end
end
