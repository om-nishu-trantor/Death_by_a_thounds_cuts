class SessionsController < ApplicationController

  def new
    redirect_to issues_path if current_user
  end  
    
  def create
    user = User.authenticate(params[:user_name], params[:password])
    if user
      session[:user_id] = user.id  
      redirect_to root_url, :notice => "Logged in!"  
    else  
      flash.now[:danger] = "Invalid username or password"  
      render "new"  
    end  
  end 

  def destroy  
  	session[:user_id] = nil  
    flash[:success] = "Logged out!"
  	redirect_to root_url
	end 
end
