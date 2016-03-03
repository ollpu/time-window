class ShowsController < ApplicationController
  def index
    # Scopes
    @shows = Show.all
  end
  
  def new
    @show = Show.new
  end
end
