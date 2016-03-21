class IndexPolicy < ApplicationPolicy
  def index?
    user
  end
end
