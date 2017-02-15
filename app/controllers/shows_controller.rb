class ShowsController < ApplicationController
  def index # Show all shows (the user can access)
    authorize Show
    @shows = policy_scope(Show)
  end
  
  def new # Create a new show, and show it
    @show = Show.new
    @show.owners << current_user.id
    authorize @show
    @show.save
    current_user.save
    render :show
  end
  
  def show # Edit or host show
    @show = Show.find(params[:id])
    authorize @show
  end
  
  def update # Save updates to show
    @show = Show.find(params[:id])
    authorize @show
    if @show.update! show_params
      redirect_to show_path(@show)
    else
      # Invalid .. TODO
    end
  end
  
  def destroy # Destroy show
    @show = Show.find(params[:id])
    authorize @show
    @show.destroy
    redirect_to shows_path
  end
  
  def live_client # Display client-page
    @urlid = params[:urlid]
    @show = Show.find_by(urlid: @urlid)
    authorize :show
  end
  
  def regen # Regenerate urlid for show
    @show = Show.find(params[:id])
    authorize @show
    @show.generate_urlid
    @show.save
    redirect_to @show
  end
  
  def owners
    @show = Show.find(params[:id])
    authorize @show
    @owners = get_show_owners(@show)
    render layout: false
  end
  
  def update_owners
    @show = Show.find(params[:id])
    authorize @show
    @owners = set_show_owners @show
    if @show.errors.none? # Note: The show isn't ever actually validated,
                          # so using .valid? won't work properly.
      @show.save
      head :ok
    else
      render :owners, status: 422, layout: false
    end
  end
  
  private
    def show_params # Allowed parameters for editing show
      params.require(:show).permit(
        :title,
        names: [],
        times: []
      )
    end
    
    def get_show_owners show
      emails = show.owners_as_emails(current_user.id)
      Hash[emails.collect { |e| [e, true] }] # Make it into a hash: {"email" => true}
    end
    def set_show_owners show
      input = params[:show][:owners]
      if input.is_a? Array
        input.delete(current_user.email) # Make sure that current_user is kept
                                         # in the owners by adding it manually
        show.set_owners_by_emails input, current_user.id
      end
    end
end
