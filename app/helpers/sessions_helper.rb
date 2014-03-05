module SessionsHelper

def project_list projects
	list = [["ALL","ALL"]] 
	list = list + projects unless list.nil?
	list
end

end
