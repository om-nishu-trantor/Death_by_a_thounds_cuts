class ApplicationController < ActionController::Base  
  protect_from_forgery  
  helper_method :current_user  

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  def authenticate_user!
  	unless current_user
  		flash[:notice] = "Not Authorised to use"
  		redirect_to log_in_path
  	end	
  end	
    
  private  
  def current_user  
    @current_user ||= User.find(session[:user_id]) if session[:user_id]  
  end
end  