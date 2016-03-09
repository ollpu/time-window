require 'securerandom'
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_action :set_visitor_id
  private
    def set_visitor_id
      cookies.signed[:visitor_id] ||= SecureRandom.urlsafe_base64 24
    end
end
