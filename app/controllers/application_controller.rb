class ApplicationController < ActionController::Base 
  protect_from_forgery
  helper_method :current_user, :projects, :users, :all_users_with_id, :issue_types, :assigned_to  

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

  def projects
    # Moin - delete below shits if @projects variable is not required somewhere down deep
      # Also, create a helper for options_for_project_select
    # @projects = []
    # projects = 
    # @projects = projects.collect! { |c| [ c, c ] }  if projects
    Project.active
  end  

  def users
    @users = []
    users =  current_user.isAdmin ? User.all.map(&:Name) : ['RAJAT JULKA']
    @users = users.collect! { |c| [ c, c ] } if users
  end

  def all_users_with_id
    @users = []
    users =  current_user.isAdmin ? User.all : [User.find_by_Name("RAJAT JULKA")]
    @users = users.collect! { |c| [c.Name, c.objectId] } if users  
  end

  def get_file_format(file_to_upload)
    fmt = file_to_upload.original_filename.split('.')
    indx = fmt.length - 1
    return fmt[indx].downcase
  end

  def issue_types
    @issue_types = []
    @issue_types =  IssueTypes.all.map(&:IssueType) 
  end

  def assigned_to
    @assigned_to = []
    @assigned_to =  Issues.all.map(&:assignedTo) 
  end

end