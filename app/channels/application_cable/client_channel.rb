class ClientChannel < ApplicationCable::Channel
  def subscribed # Client starts viewing a show
    # All status-updates will go through this stream
    stream_from "client_for_#{params[:urlid]}"
    # Inform the client about the server-time, so that all parties will be in sync
    transmit({ timestamp: (Time.now.to_f * 1000).round })
    # Request the host for a status update, to initialize this client
    ActionCable.server.broadcast "host_for_#{params[:urlid]}", { request: true }
  end
end
