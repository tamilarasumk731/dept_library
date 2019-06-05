module Api
  module V1
    class UsersController < BaseController
      
      def approve_staff
        if @current_user.role == "Librarian"
          @user = User.find_by(staff_id: params[:staff_id])
          if @user
            @user.update(status: "Approved")
            UserMailer.staff_approval(@user).deliver_now!
            render json: {success: true, message: "Staff approval success"}, status: :ok and return
          else
            render json: {success: false, message: "Staff not found"}, status: :ok and return
          end
        else
          render json: {success: false, message: "Unauthorized access"}, status: :ok and return
        end
      end

      def assign_librarian
        if @current_user.role == "HoD"
          @user = User.find_by(staff_id: params[:staff_id])
          if @user
            @user.update(role: "Librarian")
            render json: {success: true, message: "Librarian assigned success"}, status: :ok and return
          else
            render json: {success: false, message: "Staff not found"}, status: :ok and return
          end
        else
          render json: {success: false, message: "Unauthorized access"}, status: :ok and return
        end
      end     

      def assign_incharge
        if @current_user.role == "HoD"
          @user = User.find_by(staff_id: params[:staff_id])
          if @user
            @user.update(role: "Incharge")
            render json: {success: true, message: "Incharge assigned success"}, status: :ok and return
          else
            render json: {success: false, message: "Staff not found"}, status: :ok and return
          end
        else
          render json: {success: false, message: "Unauthorized access"}, status: :ok and return
        end
      end  

      def remove_librarian
        if @current_user.role == "HoD"
          @user = User.find_by(staff_id: params[:staff_id])
          if @user
            @user.update(role: "Staff")
            render json: {success: true, message: "Librarian removed success"}, status: :ok and return
          else
            render json: {success: false, message: "Staff not found"}, status: :ok and return
          end
        else
          render json: {success: false, message: "Unauthorized access"}, status: :ok and return
        end
      end

      def remove_incharge
        if @current_user.role == "HoD"
          @user = User.find_by(staff_id: params[:staff_id])
          if @user
            @user.update(role: "Staff")
            render json: {success: true, message: "Incharge removed success"}, status: :ok and return
          else
            render json: {success: false, message: "Staff not found"}, status: :ok and return
          end
        else
          render json: {success: false, message: "Unauthorized access"}, status: :ok and return
        end
      end

      def index
        @page = params[:page] || 1
        if @current_user.role == "HoD"
          @users = User.where.not(role: 0).page(@page).per(20)
        elsif @current_user.role == "Librarian"
          @users = User.where.not(role: 1).page(@page).per(20)
        elsif @current_user.role == "Incharge"
          @users = User.where.not(role: 2).page(@page).per(20)
        else
          render json: {success: false, message: "Unauthorized access"}, status: :ok and return
        end
      end

      def delete_staff
        if @current_user.role == "Librarian"
          @user = User.find_by(staff_id: params[:staff_id])
          @user.update(status: "Left")
          render json: {success: true, message: "Staff removed success"}, status: :ok and return
        else
          render json: {success: false, message: "Unauthorized access"}, status: :ok and return
        end
      end

      private

      def user_params
        params.require(:staff).permit(:staff_id, :name, :email, :role, :desig, :password)
      end

    end
  end
end