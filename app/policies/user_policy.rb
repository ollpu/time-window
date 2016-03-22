class UserPolicy < ApplicationPolicy
  def index?
    false # Admin system not implemented
    # begin
    #   user.admin?
    # rescue NoMethodError
    #   false # Admin system not implemented
    # end
  end
  
  def update?
    user && (record == user) # User can only edit itself
  end
  
  def show?
    update?
  end
  
  def destroy?
    update?
  end
  
  def create?
    true # Everyone can create a new account
  end
  
  
end
