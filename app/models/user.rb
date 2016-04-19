
require 'bcrypt'

class User < ApplicationRecord
  has_secure_password
  
  validates :email,
    presence: true,
    format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i },
    uniqueness: { case_sensitive: false }
  validates :password,
    length: { minimum: 6 },
    allow_nil: true
  
  attr_accessor :old_password
  
  def password_digest= val
    @old_password_digest = self.password_digest if val.present?
    write_attribute(:password_digest, val)
  end
  
  validate :verify_old_password
  
  private def verify_old_password
    if @old_password_digest.present?
      old = BCrypt::Password.new(@old_password_digest)
      unless old == old_password
        errors.add(:old_password, 'doesn\'t match previous password')
      end
    end
  end
end
