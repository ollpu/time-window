class ShowPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope
    
    def initialize(user, scope)
      @user = user
      @scope = scope
    end
    
    def resolve
      scope.where("? = ANY (owners)", user.id)
    end
  end
  
  def index?
    user
  end
  
  def show?
    index? and record.owners.include? user.id
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
  
  def owners?
    show?
  end
  
  def update_owners?
    update?
  end
  
  def new?
    user
  end
  
  def live_client?
    true # Everyone can view the live show
  end
end
