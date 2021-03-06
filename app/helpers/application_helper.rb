module ApplicationHelper
  
  def flash_class(level)
    case level.to_sym
    when :notice then "alert alert-success"
    when :success then "alert alert-success"
    when :error then "alert alert-danger"
    when :alert then "alert alert-danger"
    end
  end

  def options_for_projects_select(all = nil)
    projects = Project.active
    projects.unshift('ALL') if all
    projects
  end

  def options_for_users_select
    User.active.map{|user| [user.Name, user.objectId] }.unshift(['Please Select', ''])
  end
  
end
