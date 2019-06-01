module Api
  module V1
    class UsersController < BaseController

      before_action :requires_login, :except => [:create]

      def create
        @user = User.new(user_params)
        unless @user.save 
          render json: { status: false, messages: @user.errors.full_messages.to_sentence }, status: :unprocessable_entity and return
        end
      end
      
      def approve_staff
        
      end

      private

      def user_params
        params.require(:user).permit(:staff_id, :name, :email, :role, :desig, :password)
      end

    end
  end
end