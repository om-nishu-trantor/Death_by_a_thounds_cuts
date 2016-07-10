class Project < ParseResource::Base
	
  fields :ProjectName, :Archived
  validates :ProjectName, presence: true

  def self.archived
    where(Archived: true).collect { |p| p.ProjectName }
  end

  def self.active
    where(Archived: false).collect { |p| p.ProjectName }
  end

end