class SessionsController < ApplicationController
  def new
    authorize :session
  end
  
  def create
    @user = User.find_by(email: params[:email])
    authorize :session
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      flash[:notice] = "Welcome, #{@user.name}!"
      redirect_to index_path
    else
      flash[:error] = "Invalid email or password."
      render :new
    end
  end
  
  def destroy
    authorize :session
    session[:user_id] = nil
    redirect_to login_path
  end
end
