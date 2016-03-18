class HostChannel < ApplicationCable::Channel
  def subscribed # When a host starts a show
    # TODO: Allow only one host to host a show at a time
    # and check that the user is elgible for hosting this show
    # Forward all requests for data to the host
    stream_from "host_for_#{params[:urlid]}"
    # Inform the host about the server-time, so that all parties will be in sync
    transmit({ timestamp: (Time.now.to_f * 1000).round })
  end
  
  def receive data
    # Forward the status update to all listening clients
    # TODO: Maybe examine contents of data for illegal attributes
    ActionCable.server.broadcast "client_for_#{params[:urlid]}", data
  end
end
