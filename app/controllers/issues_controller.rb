class IssuesController < ApplicationController
	before_filter :authenticate_user!
	
	def index
		if params[:project]
			@issues = issue_query params[:project]
		else
			@issues = issue_query
		end
		@projects = @issues.map(&:Project).uniq if @issues
		@users =  current_user.isAdmin ? User.all.map(&:Name) : [current_user].map(&:Name)
		@users.collect! { |c| [ c, c ] unless c.nil?} if @users
		@projects.collect! { |c| [ c, c ] unless c.nil?}  if @projects
		if @issues
			@serverty = @issues.map(&:Severity)
			@closed = @issues.map(&:Status)
		end
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
		params[:issues][:isManagementIssue] = params[:issues][:isManageable] == "true" ? true : false
		params[:issues][:isDeleted] = false
		params[:issues][:assignedTo] = nil if params[:issues][:assignedTo] == "Please Select"
		params[:issues][:createdBy] = current_user.Name
		@issue = Issues.new(params[:issues])
		respond_to do |format|
			if @issue.save
				@issues = issue_query params[:issues][:Project]
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
		@users =  current_user.isAdmin ? User.all.map(&:Name) : [current_user].map(&:Name)
		@users.collect! { |c| [ c, c ] unless c.nil?} if @users
	end	

	def update
		@object_issues = Issues.find_by_objectId(params[:id])
		params[:issues][:isClosed] = params[:issues][:Status] == "CLOSED" ? true : false
		params[:issues][:closedBy] = params[:issues][:Status] == "CLOSED" ? current_user.Name : ''
		params[:issues][:assignedTo] = nil if params[:issues][:assignedTo] == "Please Select"
		params[:issues][:isManagementIssue] = params[:issues][:isManagementIssue] == "1" ? true : false
		params[:issues][:lastUpdatedBy] = current_user.Name
		@issue = @object_issues.update_attributes(params[:issues])
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

def create_full_data issues
	
	
end	


end
