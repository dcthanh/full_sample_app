class RelationshipsController < ApplicationController
  
  before_action :logged_in_user #Define in ApplicationController >> if not logged_in > store the requested url > go to login_url > go back to requested url
  
  def create
    @user = User.find(params[:followed_id])
    current_user.follow(@user) unless current_user.following?(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end
  
  def destroy
    relationship = Relationship.find_by(id: params[:id])
    @user = relationship.followed if relationship
    current_user.unfollow(@user) if @user
    respond_to do |format|
      format.html { redirect_to @user || root_url }
      format.js
    end
  end
    
end
