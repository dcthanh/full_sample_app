class UsersController < ApplicationController
  before_action :logged_in_user, only: [:following, :followers, :index, :show, :edit, :update, :destroy] #applique la méthode logged_in_user avant l'éxecution de edit et update
  before_action :correct_user, only: [:edit, :update]
  before_action :not_current_user, only: :destroy
  before_action :admin_user, only: :destroy
  
  
  def new
    @user = User.new    
  end
  
  def create
    @user = User.new(user_params)    
    if @user.save
      @user.send_activation_email
      flash[:success] = "Please check your emails to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
  end
    
  
  def show
    @user = User.find(params[:id])    
    redirect_to root_url and return unless @user.activated?
    @microposts = @user.microposts.paginate(page: params[:page])
    #debugger
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Your profile was successfully updated"
      redirect_to @user
    else      
      render 'edit'
      
    end
  end
  
  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end
    
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end    
  
  def following
    @title = "Following"
    @user = User.find(params[:id]) 
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'    
  end
  
  def followers
    @title = "Followers"
    @user = User.find(params[:id]) 
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'   
  end
  
  private
  
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
    
    def aimed_user
      User.find_by(id: params[:id])
    end   
    
    #Confirms it's an authorized action to current user
    def correct_user
      @user = User.find_by(id: params[:id])
      redirect_to root_url unless current_user?(@user)
    end
    
    #Confirms an admin user
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
    
    #Confirms that an user is not acting on itself
    def not_current_user
      @user = aimed_user
      redirect_to(root_url) if current_user?(@user)
    end  
    

end