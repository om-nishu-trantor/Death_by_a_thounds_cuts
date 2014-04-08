class Project < ParseResource::Base
	fields :ProjectName

  validates :ProjectName, :presence => true 
	
end	