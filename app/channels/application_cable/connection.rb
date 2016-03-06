# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
require 'securerandom'
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :visitor_id
    
    def connect
      self.visitor_id = get_visitor_id
    end
    
    protected
      def get_visitor_id
        if session[:visitor_id].present?
          session[:visitor_id]
        else
          session[:visitor_id] = SecureRandom.urlsafe_base64 24
        end
      end
  end
end
