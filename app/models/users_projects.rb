class UsersProjects < ParseResource::Base

  fields :ProjectId, :UserId
  validates :ProjectId, :UserId, presence: true

end