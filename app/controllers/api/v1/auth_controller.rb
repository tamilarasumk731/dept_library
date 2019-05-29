module Api
  module V1
    class AuthController < BaseController

      skip_before_action :requires_login

      def signup    
        user = User.new(auth_params)
        if  user.save
          render json:{ success: true, message: "Signup successful"}, status: :ok and return
        else
          render json: {success: false, message: user.errors.full_messages.to_sentence}
        end
      end

      def login
        user = User.find_by(staff_id: auth_params[:staff_id])
        if  user && user.authenticate(auth_params[:password])
          token = Token.encode(user.id)
          render json: { token: token, message: 'logged in successfully', staff_id: user.staff_id }
        else
          render json: { message: 'authentication failed' }, status: :bad_request and return
        end
      end

      private
      def auth_params
        params.require(:auth).permit(:staff_id, :name, :email, :role, :desig, :password)
      end

    end
  end
end
