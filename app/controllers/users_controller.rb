class UsersController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  
  def new 
    @user = User.new  
  end  
    
  def create  
    params[:user][:username] = (params[:user][:username]).downcase
    params[:user][:Name] = (params[:user][:Name]).upcase
    params[:user][:isAdmin] = false
    @user = User.new(params[:user])  
    if @user.save 
      redirect_to issues_path, :notice => "User created successfully"  
    else 
      flash.now[:danger] = @user.errors.full_messages.first
      render "new"  
    end
  end

  def edit
    @user = User.find_by_objectId(params[:id])
  end

  def update
    @user = User.find_by_objectId(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "User updated successfully"
      redirect_to edit_user_path  
    else
      flash.now[:danger] = @user.errors.full_messages.first
      redirect_to edit_user_path
    end  
  end  
end
