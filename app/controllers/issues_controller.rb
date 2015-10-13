class IssuesController < ApplicationController
	before_filter :authenticate_user!
	before_filter :check_read, :only => [:index, :fetch_issue, :create, :destroy]
	before_filter :mark_read, :only => [:show, :edit]
	
	def index
		@issues =  issue_query
		@projects = all_projects @issues
		@users = all_users
		@issues =  params[:project] == "ALL" ?	issue_query : issue_query(params[:project]) if params[:project]
		@serverty, @closed  = category(@issues)
	end	


	def fetch_issue
		@issues = params[:project] == "ALL" ?	issue_query : issue_query(params[:project])
		@serverty, @closed  = category(@issues)
		format_create response
	end

	def create
		@issues = []
		params[:issues][:isClosed] = params[:issues][:isClosed] == "true" ? true : false
		params[:issues][:isManagementIssue] = params[:issues][:isManagementIssue] == "true" ? true : false
		params[:issues][:isDeleted] = false
		params[:issues][:assignedTo] = 'RAJAT JULKA' if params[:issues][:assignedTo].blank?
		params[:issues][:createdBy] = current_user.Name
		params[:issues][:Project] = ((params[:issues][:Project]).strip).upcase
		params[:issues][:CommentsArray] = []
		@issue = Issues.new(params[:issues])
		if @issue.save
			# @issues = issue_query params[:issues][:Project]
			send_mail @issue if params[:issues][:Status] == "CLOSED"
			send_notification "create", @issue
			UserNotifier.send_create_notification_mail(@issue).deliver!
			@issues = params[:project] == "ALL" ?	issue_query : issue_query(params[:project]) if params[:project]
			@serverty, @closed  = category(@issues)
		else
			@issues = params[:project] == "ALL" ?	issue_query : issue_query(params[:project]) if params[:project]
			@serverty, @closed  = category(@issues)
		end
		format_create response
	end	

	def edit
		@object_issues = Issues.find_by_objectId(params[:id])
		if @object_issues.nil?
			flash[:notice] = "Issue not found"
			redirect_to issues_path, :notice => "Cut not found"
		end	
		@users = all_users	
	end	

	def show
		@object_issues = Issues.find_by_objectId(params[:id])
		if @object_issues.nil?
			flash[:notice] = "Issue not found"
			redirect_to issues_path, :notice => "Cut not found"
		end
		@users = all_users	
	end	

	def update
		@object_issues = Issues.find_by_objectId(params[:id])
		closed_status = (@object_issues.Status == "CLOSED")
		params[:issues][:isClosed] = params[:issues][:Status] == "CLOSED" ? true : false
		params[:issues][:closedBy] = params[:issues][:Status] == "CLOSED" ? current_user.Name : ''
		params[:issues][:assignedTo] = 'RAJAT JULKA' if params[:issues][:assignedTo].blank?
		params[:issues][:isManagementIssue] = params[:issues][:isManagementIssue] == "1" ? true : false
		comment = [[params[:issues][:CommentsArray],"Update By #{current_user.username} on #{Time.now.strftime("%d-%m-%Y %I:%M:%S")}"]]
		if (@object_issues.CommentsArray.nil? || @object_issues.CommentsArray.blank? ) && !params[:issues][:CommentsArray].blank?
			params[:issues][:CommentsArray] = comment
		elsif ( !@object_issues.CommentsArray.nil? || !@object_issues.CommentsArray.blank?) && params[:issues][:CommentsArray].blank?	
			# params[:issues][:CommentsArray] = @object_issues.CommentsArray
			params[:issues].delete :CommentsArray
		elsif ( !@object_issues.CommentsArray.nil? || !@object_issues.CommentsArray.blank?) && !params[:issues][:CommentsArray].blank?
			params[:issues][:CommentsArray] = @object_issues.CommentsArray + comment	
		elsif (@object_issues.CommentsArray.nil? || @object_issues.CommentsArray.blank?) && params[:issues][:CommentsArray].blank?
			# params[:issues][:CommentsArray] = []
			params[:issues].delete :CommentsArray
		end	
		params[:issues][:lastUpdatedBy] = current_user.Name
		params[:issues][:Project] = ((params[:issues][:Project]).strip).upcase	
		@issue = @object_issues.update_attributes(params[:issues])
		
		if @issue
			send_notification "update", @object_issues
			mark_unread @object_issues.objectId
			if params[:issues][:Status] == "CLOSED" && !closed_status
				send_mail @object_issues
			else	
				UserNotifier.send_update_notification_mail(@object_issues).deliver!
			end
		end
		# @serverty, @closed  = category(@issues)	
		redirect_to issues_path(:project => params[:project])
	end


	def destroy 
		issue = Issues.find_by_objectId(params[:id])
		issue_create = issue.update_attributes(:isDeleted => true ,:deletedBy => current_user.Name,:lastUpdatedBy => current_user.Name) if issue 
		if issue_create
			send_notification "delete", issue
			mark_unread issue.objectId
			UserNotifier.send_delete_notification_mail(issue).deliver!
		end	
		@issues = params[:project] == "ALL" ?	issue_query : issue_query(params[:project]) if params[:project]
		@issues = issue_query if @issues.blank?
		@serverty, @closed  = category(@issues)	
		format_create response	
	end	

	def issue_query project = nil
		issues = Issues.where(query(project)).all
		unless  current_user.isAdmin
			issues = issues + Issues.where(get_created_by_data(project)).all
		end
		issues	
	end

	def get_created_by_data project
		query = {:isDeleted => false}
		query.merge!(:createdBy => current_user.Name)
		query.merge!(:Project => project)  if project
		query
	end	

	def query project
		query = {:isDeleted => false}
		query.merge!(:assignedTo => current_user.Name)  unless  current_user.isAdmin
		query.merge!(:Project => project)  if project
		query
	end	

	def format_create response
		respond_to do |format|
			format.html { render :partial => "project_list" , :layout => false }
		end
	end	

	def report
		@users = all_users
		@issues_obj = issue_query
		@issues = []
		@projects = @issues_obj.map(&:Project).uniq if @issues_obj
		@projects.collect! { |c| [ c, c ] unless c.nil?}  if @projects
	end	

	def fetch_issue_report
		@issues = setupdata params
		respond_to do |format|
			format.html { render :partial => "project_list_report" , :layout => false }
		end
	end	
	def pdf_report
		@issues = setupdata params
		respond_to do |format|
			format.html
			format.pdf do
				render	:pdf => "sample",
								:header => {:html => { :template => 'issues/header.html.erb'}, :spacing => 5},
								:footer => {:html => { :template => 'issues/footer.html.erb'}}
      end
    end
  end	

  def send_mail object
  	UserNotifier.send_close_notification_mail(object).deliver!
  end	

  def setupdata params
  	if params[:project] == "ALL"
  		@issues = issue_query
  		@issues.select{|issue| ((params[:start_date].to_date)..(params[:end_date].to_date)) === issue.dateIdentified.to_date }
  	else
  		@issues = issue_query params[:project]
  		@issues.select{|issue| ((params[:start_date].to_date)..(params[:end_date].to_date)) === issue.dateIdentified.to_date }
  	end
  end	

  def all_users
  	users =  current_user.isAdmin ? User.all.map(&:Name) : ['RAJAT JULKA']
  	users.collect! { |c| [ c, c ] } if users
  end

  def all_projects issues
  	projects = @issues.map(&:Project).uniq if issues
  	projects.collect! { |c| [ c, c ] }  if projects
  end

  def category issues
  	serverty = status = []
  	if issues 
  		serverty = issues.map(&:Severity)
  		status = issues.map(&:Status)
  	end
  	return 	serverty, status
  end

  def check_read
  	@read_issues = []
  	read_iss = WebRead.find_all_by_user_id(current_user.objectId)
 	@read_issues = read_iss.map(&:issues_id) if !read_iss.blank?
  end	

  def mark_read
  	read_issues = WebRead.where(:user_id =>current_user.objectId ,:issues_id => params[:id] ).first
  	WebRead.create(:user_id => current_user.objectId, :issues_id => params[:id] ) if read_issues.nil?
  end	

  def mark_unread id
	read_issues = WebRead.find_all_by_issues_id id
	read_issues.select!{|s| s.user_id != current_user.objectId}
	WebRead.destroy_all(read_issues) unless read_issues.blank?
  end	

  def send_notification type, object
  	data =  if type == "create"
  		{ :alert => "Cut #{object.title} for project #{object.Project} has been created by user #{object.createdBy}" }
	elsif type == "update"
		{ :alert => "Cut #{object.title} for project #{object.Project} has been updated by user #{object.lastUpdatedBy}"}
	elsif type == "delete"
		{ :alert => "Cut #{object.title} for project #{object.Project} has been delete by user #{object.deletedBy}"}
	end			
	push = Parse::Push.new(data, "DBTC")
	push.type = "ios"
	push.save
  end	


end
