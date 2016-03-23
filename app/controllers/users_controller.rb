class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  
  def index
    authorize :user
    @users = User.all
  end
  
  def show
    authorize @user
  end
  
  def new
    @user = User.new
    authorize @user
  end
  
  def create
    @user = User.new(user_create_params)
    authorize @user
    
    respond_to do |format|
      if @user.save
        session[:current_user] = @user.id
        format.html { redirect_to index_path, notice: 'Registration successful. Welcome!' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    @user = User.find(params[:id])
    authorize @user
    respond_to do |format|
      if @user.update(user_update_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :show }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    authorize @user
    @user.destroy
    respond_to do |format|
      format.html { redirect_to login_path, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
    end
    
    def user_create_params
      params.require(:user).permit(
        :email,
        :name,
        :password,
        :password_confirmation
      )
    end
    
    def user_update_params
      params.require(:user).permit(
        :name,
        :password,
        :password_confirmation,
        :old_password
      )
    end
end
