class UsersController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  def new 
    @users =  current_user.isAdmin ? User.all.map(&:Name) : ['RAJAT JULKA']
    @users.collect! { |c| [ c, c ] } if @users 
    @user = User.new  
  end  
    
  def create  
    @users =  current_user.isAdmin ? User.all.map(&:Name) : ['RAJAT JULKA']
    @users.collect! { |c| [ c, c ] } if @users  
    @user = User.new(params[:user])  
    if @user.save  
      redirect_to root_url, :notice => "Signed up!"  
    else  
      render "new"  
    end  
  end
end
