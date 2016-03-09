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
  
  def destroy
    @show = Show.find(params[:id])
    @show.destroy
    redirect_to shows_path
  end
  
  def live_client
    @urlid = params[:urlid]
    @show = Show.where(urlid: @urlid).first
  end
  
  def regen
    @show = Show.find(params[:id])
    @show.generate_urlid
    @show.save
    redirect_to @show
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
