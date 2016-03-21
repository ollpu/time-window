class ShowPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope
    
    def initialize(user, scope)
      @user = user
      @scope = scope
    end
    
    def resolve
      scope.where(id: user.owned_shows)
    end
  end
  
  def index?
    user
  end
  
  def show?
    record.owners.include? user.id
  end
  
  def update?
    show?
  end
  
  def destroy?
    show?
  end
  
  def regen?
    show?
  end
  
  def new?
    user
  end
  
  def live_client
    true # Everyone can view the live show
  end
end
