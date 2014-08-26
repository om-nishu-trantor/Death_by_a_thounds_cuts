class Project < ParseResource::Base
  fields :ProjectName

  validates :ProjectName, :presence => true

  has_many :issues, :inverse_of => :project
  belongs_to :user
end	