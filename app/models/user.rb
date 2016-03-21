
class User < ApplicationRecord
  has_secure_password
  
  validates :email,
    presence: true,
    format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i },
    uniqueness: { case_sensitive: false }
  validates :password,
    length: { minimum: 6 },
    allow_nil: true
  
  def add_own(show)
    self.owned_shows << show.id
  end
end
