class ShowsController < ApplicationController
  def index
    # Scopes
    @shows = Show.all
  end
  
  def new
    @show = Show.new
    @show.save
    render :show
  end
  
  def show
    @show = Show.find(params[:id])
  end
  
  def update
    @show = Show.find(params[:id])
    if @show.update! show_params
      redirect_to show_path(@show)
    else
      # Invalid .. TODO
    end
  end
  
  private
    def show_params
      params.require(:show).permit(
        :title,
        names: [],
        times: []
      )
    end
end
