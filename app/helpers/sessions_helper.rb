module SessionsHelper

def project_list projects
	list = [["All","All"]] 
	list = list + projects unless list.nil?
	list
end

end
