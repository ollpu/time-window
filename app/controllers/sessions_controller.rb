class SessionsController < ApplicationController
  def new
    authorize :session
  end
  
  def create
    @user = User.find_by(email: params[:email])
    authorize :session
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      cookies.signed[:user_id] = @user.id # For Cable
      flash[:notice] = "Welcome, #{@user.name}!"
      redirect_to index_path
    else
      flash[:error] = "Invalid email or password."
      @rejected = true
      render :new
    end
  end
  
  def destroy
    authorize :session
    session[:user_id] = nil
    cookies.signed[:user_id] = nil
    redirect_to login_path
  end
end
