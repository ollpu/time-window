require 'securerandom'
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  include Pundit
  after_action :verify_authorized
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  
  helper_method :current_user
  
  before_action :set_visitor_id
  private
    def set_visitor_id
      cookies.signed[:visitor_id] ||= SecureRandom.urlsafe_base64 24
    end
    
    def user_not_authorized
      unless current_user
        # Not logged in
        flash[:notice] = "Please log in first."
        redirect_to login_path(navigate: request.env['PATH_INFO'])
      else
        # Logged in but not otherwise authorized
        flash[:alert] = "Not authorized."
        redirect_to index_path
      end
    end
    
    def current_user
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end
end
