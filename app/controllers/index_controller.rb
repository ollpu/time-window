class IndexController < ApplicationController
  def index # The frontpage
    authorize :index
  end
end
