class HostChannel < ApplicationCable::Channel
  def subscribed
    stream_from "host_for_#{params[:urlid]}"
    transmit({ timestamp: (Time.now.to_f * 1000).round })
  end
  
  
  def receive data
    ActionCable.server.broadcast "client_for_#{params[:urlid]}", data
  end
end
