class ClientChannel < ApplicationCable::Channel
  def subscribed
    stream_from "client_for_#{params[:urlid]}"
    transmit({ timestamp: (Time.now.to_f * 1000).round })
    ActionCable.server.broadcast "host_for_#{params[:urlid]}", { request: true }
  end
  
  def unsubscribed
  end
end
