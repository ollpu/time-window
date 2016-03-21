class SessionPolicy < ApplicationPolicy
  def new?
    true # Everyone view the login page
  end
  
  def create?
    true # Everyone can register
  end
  
  def destroy?
    user # User can log out if previously logged in
  end
end
