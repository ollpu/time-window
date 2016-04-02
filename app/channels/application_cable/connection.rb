# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
require 'securerandom'
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :visitor_id, :current_user
    
    def connect
      self.visitor_id = get_visitor_id
      self.current_user = get_current_user
    end
    
    protected
      def get_visitor_id
        cookies.signed[:visitor_id] || SecureRandom.urlsafe_base64(24)
      end
      
      def get_current_user
        User.find_by_id(cookies.signed[:user_id])
      end
  end
end
