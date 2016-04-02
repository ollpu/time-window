class HostChannel < ApplicationCable::Channel
  
  def subscribed # When a host starts a show
    @show = Show.find_by(urlid: params[:urlid])
    if current_user && @show && @show.owners.include?(current_user.id)
      unless @show.live
        # Forward all requests for data to the host
        stream_from "host_for_#{params[:urlid]}"
        # Inform the host about the server-time, so that all parties will be in sync
        transmit({ timestamp: (Time.now.to_f * 1000).round })
        @show.update!(live: true)
      else
        # Someone is already hosting the show
        if params[:kick]
          
        else
          # TODO: Tell the new host that someone is already hosting the show,
          # and ask if they want to end the other session
          transmit({ reserved: true })
        end
      end
    else
      reject
    end
  end
  
  def unsubscribed
    @show.update!(live: false)
    ActionCable.server.broadcast "client_for_#{params[:urlid]}", {
      "show_stopped" => true
    }
    # TODO: Inform the clients that the host has left
  end
  
  def receive data
    # Forward the status update to all listening clients
    ActionCable.server.broadcast "client_for_#{params[:urlid]}", data.slice(
      'play', 'cue_name', 'next_cue', 'remaining', 'over', 'next_cue_name'
    )
  end
end
