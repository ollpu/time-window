class ShowsController < ApplicationController
  def index # Show all shows (the user can access)
    # TODO: Scopes
    @shows = Show.all
  end
  
  def new # Create a new show, and show it
    @show = Show.new
    @show.save
    render :show
  end
  
  def show # Edit or host show
    @show = Show.find(params[:id])
  end
  
  def update # Save updates to show
    @show = Show.find(params[:id])
    if @show.update! show_params
      redirect_to show_path(@show)
    else
      # Invalid .. TODO
    end
  end
  
  def destroy # Destroy show
    @show = Show.find(params[:id])
    @show.destroy
    redirect_to shows_path
  end
  
  def live_client # Display client-page
    @urlid = params[:urlid]
    @show = Show.find_by(urlid: @urlid)
  end
  
  def regen # Regenerate urlid for show
    @show = Show.find(params[:id])
    @show.generate_urlid
    @show.save
    redirect_to @show
  end
  
  private
    def show_params # Allowed parameters for editing show
      params.require(:show).permit(
        :title,
        names: [],
        times: []
      )
    end
end
