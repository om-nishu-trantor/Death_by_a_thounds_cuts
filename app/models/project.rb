class Project < ParseResource::Base
	
  fields :ProjectName, :Archived
  validates :ProjectName, presence: true

end