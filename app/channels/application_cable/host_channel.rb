class HostChannel < ApplicationCable::Channel
  def subscribed
    stream_from "host_for_#{params[:urlid]}"
  end
  
  def unsubscribed
  end
  
  def receive data
    ActionCable.server.broadcast "client_for_#{params[:urlid]}", data
  end
end
