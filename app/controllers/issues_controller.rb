class IssuesController < ApplicationController
	before_filter :authenticate_user!
	
	def index
		@issues =  params[:project] ? issue_query(params[:project]) : issue_query
		@projects = all_projects @issues
		@users = all_users
		@serverty, @closed  = category(@issues)
	end	


	def fetch_issue
		if params[:project] == "All"
			@issues = issue_query	
		else
			@issues = issue_query params[:project]
		end
		if @issues
			@serverty = @issues.map(&:Severity)
			@closed = @issues.map(&:Status)
		end
		respond_to do |format|
			format.html { render :partial => "project_list" , :layout => false }
		end
		
	end

	def create
		params[:issues][:isClosed] = params[:issues][:isClosed] == "true" ? true : false
		params[:issues][:isManagementIssue] = params[:issues][:isManagementIssue] == "true" ? true : false
		params[:issues][:isDeleted] = false
		params[:issues][:assignedTo] = nil if params[:issues][:assignedTo] == "Please Select"
		params[:issues][:createdBy] = current_user.Name
		@issue = Issues.new(params[:issues])
		respond_to do |format|
			if @issue.save
				@issues = issue_query params[:issues][:Project]
				send_mail @issue if params[:issues][:Status] == "CLOSED"
				if @issues
					@serverty = @issues.map(&:Severity)
					@closed = @issues.map(&:Status)
				end
				
				format.html { render :partial => "project_list" , :layout => false }
			else
				@issues = issue_query params[:issues][:Project]
				if @issues
					@serverty = @issues.map(&:Severity)
					@closed = @issues.map(&:Status)
				end
				format.html { render :partial => "project_list" , :layout => false }
			end
		end
	end	

	def edit
		@object_issues = Issues.find_by_objectId(params[:id])
		@users = all_users	
	end	

	def update
		@object_issues = Issues.find_by_objectId(params[:id])
		params[:issues][:isClosed] = params[:issues][:Status] == "CLOSED" ? true : false
		params[:issues][:closedBy] = params[:issues][:Status] == "CLOSED" ? current_user.Name : ''
		params[:issues][:assignedTo] = nil if params[:issues][:assignedTo] == "Please Select"
		params[:issues][:isManagementIssue] = params[:issues][:isManagementIssue] == "1" ? true : false
		comment = [[params[:issues][:CommentsArray],"Update By #{current_user.username} on #{Time.now.strftime("%d-%m-%Y %I:%M:%S")}"]]
		if @object_issues.CommentsArray.nil? && !params[:issues][:CommentsArray].blank?
			params[:issues][:CommentsArray] = comment
		elsif !@object_issues.CommentsArray.nil? && params[:issues][:CommentsArray].blank?	
			params[:issues][:CommentsArray] = @object_issues.CommentsArray
		else
			params[:issues][:CommentsArray] = @object_issues.CommentsArray + comment	
		end	
		params[:issues][:lastUpdatedBy] = current_user.Name
		@issue = @object_issues.update_attributes(params[:issues])
		send_mail @object_issues if params[:issues][:Status] == "CLOSED"
		if @issues 
			@serverty = @issues.map(&:Severity)
			@closed = @issues.map(&:Status)
		end	
		redirect_to issues_path(:project => params[:issues][:Project])
	end


	def destroy 
		issue = Issues.find_by_objectId(params[:id])
		if issue 
			issue.update_attributes(:isDeleted => true ,:deletedBy => current_user.Name,:lastUpdatedBy => current_user.Name)
		end	
		@issues = issue_query issue.Project
		if @issues
			@serverty = @issues.map(&:Severity)
			@closed = @issues.map(&:Status)
		end	
		respond_to do |format|
			format.html { render :partial => "project_list" , :layout => false }
		end	
	end	

	def issue_query project = nil
		if project
			if current_user.isAdmin
				Issues.where(:Project => project, :isDeleted => false).all
			else
				Issues.where(:Project => project, :isDeleted => false, :assignedTo => current_user.Name).all
			end	
		else
			if current_user.isAdmin
				Issues.where(:isDeleted => false).all
			else
				Issues.where(:isDeleted => false, :assignedTo => current_user.Name).all
			end	
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
		setupdata params
		respond_to do |format|
			format.html
			format.pdf do
				render :pdf => "sample",
				:header => {:html => { :template => 'issues/header.html.erb'}, :spacing => 5},
				:footer => {:html => { :template => 'issues/footer.html.erb'}},
          		:margin => {:top                => 10,                     # default 10 (mm)
          			:bottom             => 10,
          			:left               => 10,
          			:right              => 10}
      end
    end
  end	


  def send_mail object
  	UserNotifier.send_close_notification_mail(object).deliver!
  end	

  def setupdata params
  	if params[:project] == "All"
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
