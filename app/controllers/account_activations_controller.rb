class AccountActivationsController < ApplicationController
  def edit
    token = params[:id]   #Gets the token, which the id of AccountActivation object
    email = params[:email]
    user = User.find_by(email: email)
    if user && user.authenticated?(:activation, token)
      user.activate
      flash[:success] = "Account activated !"
      log_in user
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end
