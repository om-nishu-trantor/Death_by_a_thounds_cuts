module SessionsHelper

def project_list projects
	list = [["Select Project","Select Project"]] 
	list = list + projects unless list.nil?
	list
end

end
