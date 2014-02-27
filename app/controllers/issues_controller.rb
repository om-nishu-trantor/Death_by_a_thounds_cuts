class IssuesController < ApplicationController
	before_filter :authenticate_user!
def index
	projects = []
	if params[:project]
		@issues = Issues.where(:Project => params[:project], :isDeleted => false) if params[:project]
	else
		@issues = Issues.where(:isDeleted => false).all
	end	
	# @projects = ["MARKETLIVE", "CAN", nil, "LA JOLLA", "ADARA", "BRANDING", "DEALTRACTION", "FRYS ELECTRONICS", "JUGNOO", "LINK YOGI", "MOODYS"]
	@projects = @issues.map(&:Project).uniq if @issues
	@projects.collect! { |c| [ c, c ] unless c.nil?}  if @projects
end	


def fetch_issue
	@issues = Issues.where(:Project => params[:project], :isDeleted => false)
	respond_to do |format|
		format.html { render :partial => "project_list" , :layout => false }
	end
end

def create
	params[:issues][:isClosed] = params[:issues][:isClosed] == "true" ? true : false
	params[:issues][:isDeleted] = false
	@issue = Issues.new(params[:issues])
    respond_to do |format|
      if @issue.save
      	@issues = Issues.where(:Project => params[:issues][:Project], :isDeleted => false)
        format.html { render :partial => "project_list" , :layout => false }
      else
        format.html { render :partial => "project_list" , :layout => false }
      end
    end
end	

def edit
	@object_issues = Issues.find_by_objectId(params[:id])
end	

def update
	@object_issues = Issues.find_by_objectId(params[:id])
	params[:issues][:isClosed] = params[:issues][:Status] == "CLOSED" ? true : false
	params[:issues][:closedBy] = current_user.username if params[:issues][:Status] == "CLOSED"
	@issue = @object_issues.update_attributes(params[:issues])
    redirect_to issues_path(:project => params[:issues][:Project])
end


def destroy 
	issue = Issues.find_by_objectId(params[:id])
	if issue 
		issue.update_attributes(:isDeleted => true ,:deletedBy => current_user.email)
	end	
	@issues = Issues.where(:Project => issue.Project, :isDeleted => false)
	respond_to do |format|
		format.html { render :partial => "project_list" , :layout => false }
	end	
end	
end
