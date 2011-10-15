class SessionsController < ApplicationController
  def new
  end
  
  def create
    user = User.find_by_email(params[:email].downcase)
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_url, :notice => "Welcome back, #{user.first_name}."
    else
      flash.now.alert = 'Email or password was invalid'
      render :new
    end
  end
  
  def destroy
    session[:user_id] = nil  
    redirect_to root_url, :notice => "Logged out!"
  end
end
