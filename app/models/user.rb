class User < ParseUser

	alias :email :username

	fields :username, :Name, :password, :email
	validates_presence_of :username, :Name, :password, :email
	validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  
	EMAILNOTIFYTEST = ["nitish.verma@trantorinc.com","kapil.handa@trantorinc.com"]
	EMAILNOTIFYMAIN = ["rajat.julka@trantorinc.com","pradeep@trantorinc.com"]

  def self.active
    User.all
  end

  def projects
    UsersProjects.where(UserId: self.objectId)
  end

  def project_ids
    UsersProjects.where(UserId: self.objectId).collect {|up| up.ProjectId }
  end

end