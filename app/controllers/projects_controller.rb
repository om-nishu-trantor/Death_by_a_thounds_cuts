class ProjectsController < ApplicationController

  def index
    @project = Project.new
    @projects = current_user.projects
  end

  def create
    @error = nil
    @project = Project.new(params[:project])
    params[:project][:ProjectName] = params[:project][:ProjectName].strip.upcase
    @error = "Project should be unique, please reload page to get new projects if project is not in list" if Project.find_by_ProjectName(params[:project][:ProjectName])
    if @error.nil?
      if @project.save
        @success = "Project #{params[:project][:ProjectName]} created successfully"
      else
        @error = @project.errors
      end
    end
  end

  def destroy
    project = Project.find_by_objectId(params[:id])
    respond_to do |format|
      if project
        if project.destroy
          format.html { render :text => "Project deleted successfully", :layout => false, :valid => true }
        else
          format.html { render :text => "Something went wrong", :layout => false, :valid => false }
        end
      else
        format.html { render :text => "Project deleted successfully", :layout => false, :valid => true }
      end
    end
  end
end


# Create users and projects
require 'csv'

password = 'welcome1'
projects = []
proj_names = []

CSV.foreach('/home/raj/Desktop/teamleads.csv') do |row|
  name = row[0].downcase
  email = (row[2].present? ? row[2] : "#{name.split(' ').join('.')}@trantorinc.com").strip
  puts email
  username = email.split('@')[0].strip.downcase
  puts username

  User.create(:email => email, :Name => row[0].strip, :password => password, :username => username, :isAdmin => false)

  begin
    if row[1] != 'ALL PROJECTS'
      row[1].split(',').each do |project|
        project = project.strip
        proj = Project.find_by_ProjectName(project)

        if !proj && !proj_names.include?(project)
          proj_names << project
          puts proj = Project.new(:ProjectName => project)
          projects << proj
        end
      end
    end
  rescue Exception => e
    puts e.backtrace
    raise e.message
  end
end

Project.save_all(projects)


# Assign projects

all_projects = Project.all

CSV.foreach('/home/raj/Desktop/teamleads.csv') do |row|
  name = row[0].downcase
  email = (row[2].present? ? row[2] : "#{name.split(' ').join('.')}@trantorinc.com").strip
  username = email.split('@')[0].strip.downcase
  puts username

  user = User.find_by_username(username)

  begin
    if user
      if row[1] == 'ALL PROJECTS'
        user.projects = all_projects
      else
        row[1].split(',').each do |project_name|
          project_name = project_name.strip
          project = Project.find_by_ProjectName(project_name)

          user.projects << project
        end
      end

      user.password = password
      user.save
    end
  rescue Exception => e
    puts e.backtrace
    raise e.message
  end
end
