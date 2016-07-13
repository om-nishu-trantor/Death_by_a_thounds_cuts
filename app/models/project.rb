class Project < ParseResource::Base
	
  fields :ProjectName, :Archived
  validates :ProjectName, presence: true

  def self.archived
    where(Archived: true).collect { |p| p.ProjectName }
  end

  def self.active
    where(Archived: false).sort_by{|p| p.ProjectName}.collect { |p| p.ProjectName }
  end

end