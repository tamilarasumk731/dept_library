module Api
  module V1
    class BaseController < ApplicationController
      before_action :set_current_user
      before_action :requires_login

      attr_reader :current_user
      helper_method :current_user

      protected
      
      def requires_login
        return if current_user_present?
        render json: { meta: {success: false, msg: 'No logged in user'} }, status: :ok and return
      end

      def current_user_present?
        current_user.present?
      end

      def check_role_for_authorization
        if @current_user.role == "Librarian"
          true
        else
          render json: {success: false, message: "Unauthorized access"}, status: :ok and return
        end
      end

      def all_role_authorization
        if @current_user.role == "Librarian" || @current_user.role == "HoD" || @current_user.role == "Incharge"
          true
        else
          render json: {success: false, message: "Unauthorized access"}, status: :ok and return
        end
      end

      def set_current_user
        begin
          token = request.headers['Authorization'][15..-1].to_s
          return unless token
          payload = Token.new(token)
          @current_user = User.find(payload.user_id) if payload.valid?
        rescue Exception => e
          return render json: {success: false, error: e.message }, status: :ok
        end
      end
    end
  end
end
