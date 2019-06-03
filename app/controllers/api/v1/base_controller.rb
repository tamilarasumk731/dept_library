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
        render json: { meta: {status: false, msg: 'No logged in user'} }, status: 401
      end

      def current_user_present?
        current_user.present?
      end

      def set_current_user
        begin
          token = request.headers['Authorization'].to_s
          return unless token
          payload = Token.new(token)
          @current_user = User.find(payload.user_id) if payload.valid?
        rescue Exception => e
          return render json: {success: false, error: e.message }, status: :unprocessable_entity
        end
      end
    end
  end
end
