class SessionsController < ApplicationController
  def new
    
  end
  
  def create
    @user = User.find_by(email: params[:email])
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      flash[:notice] = "Welcome, #{@user.name}"
      redirect_to index_path
    else
      flash[:error] = "Invalid email or password."
      render :new
    end
  end
  
  def destroy
    session[:user_id] = nil
    redirect_to login_path
  end
end
