module ApplicationHelper
  def project_list(projects, blank = true)
    options = projects.collect(&:ProjectName)

    if blank
      [["ALL", "ALL"]] +  options
    else
      options
    end
  end
end
