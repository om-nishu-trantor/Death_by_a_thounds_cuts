class SessionsController < ApplicationController
  def new
    redirect_to  issues_path if current_user 
  end  
    
  def create  
    user = User.authenticate(params[:user_name], params[:password])  
    if user  
      session[:user_id] = user.id  
      redirect_to root_url, :notice => "Logged in!"  
    else  
      flash.now.alert = "Invalid email or password"  
      render "new"  
    end  
  end 

  def destroy  
  	session[:user_id] = nil  
  	redirect_to root_url, :notice => "Logged out!"  
	end 
end
