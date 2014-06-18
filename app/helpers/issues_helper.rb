module IssuesHelper
def image_icon arg
 return "h_red_icon.png" if arg == "HIGH"
 return "m_blue.png" if arg == "MEDIUM"
 return "l_green_icon.png "if arg == "LOW"	
end	

def status
	[["Assigned","Assigned"],["On Hold","On Hold"],["Resolved","Resolved"]]
end

def servity
	[["LOW","LOW"],["MEDIUM","MEDIUM"],["HIGH","HIGH"]]
end	


end
