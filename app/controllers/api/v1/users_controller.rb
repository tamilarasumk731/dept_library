module Api
  module V1
    class UsersController < BaseController

      def create
        @user = User.new(user_params)
        unless @user.save 
          render json: { status: false, messages: @user.errors.full_messages.to_sentence }, status: :unprocessable_entity and return
        end
      end
      
      def approve_staff
        if @current_user.role == "Librarian"
          @staff = User.find_by(staff_id: params(:staff_id))
          @staff.update(status: "Approved")
          render json: {success: true, message: "Staff approved"}, status: :ok and return
        else
          render json: {success: false, message: "Unauthorized access"}, status: :unauthorized_access and return
        end
        
      end

      private

      def user_params
        params.require(:staff).permit(:staff_id, :name, :email, :role, :desig, :password)
      end



    end
  end
end