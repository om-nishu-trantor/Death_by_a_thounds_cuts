class IssuesController < ApplicationController
	before_filter :authenticate_user!
	
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
		send_mail @object_issues if params[:issues][:Status] == "CLOSED"
		# @serverty, @closed  = category(@issues)	
		redirect_to issues_path(:project => params[:project])
	end


	def destroy 
		issue = Issues.find_by_objectId(params[:id])
		issue.update_attributes(:isDeleted => true ,:deletedBy => current_user.Name,:lastUpdatedBy => current_user.Name) if issue 
		@issues = params[:project] == "ALL" ?	issue_query : issue_query(params[:project]) if params[:project]
		@issues = issue_query if @issues.blank?
		@serverty, @closed  = category(@issues)	
		format_create response	
	end	

	def issue_query project = nil
			Issues.where(query(project)).all
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
  		@issues.select!{|issue| ((params[:start_date].to_date)..(params[:end_date].to_date)) === issue.dateIdentified.to_date }
  	else
  		@issues = issue_query params[:project]
  		@issues.select!{|issue| ((params[:start_date].to_date)..(params[:end_date].to_date)) === issue.dateIdentified.to_date }
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
end
