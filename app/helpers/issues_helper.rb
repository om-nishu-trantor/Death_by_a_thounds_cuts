module IssuesHelper
def image_icon arg
 return "h_red_icon.png" if arg == "HIGH"
 return "m_blue.png" if arg == "MEDIUM"
 return "l_green_icon.png "if arg == "LOW"	
end	

end
