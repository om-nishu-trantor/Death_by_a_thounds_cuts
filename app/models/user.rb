class User < ParseUser
  alias :email :username
  fields :username, :Name, :password, :email
  validates_presence_of :username, :Name, :password, :email
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  EMAILNOTIFYTEST = ["nitish.verma@trantorinc.com", "mahinder.kumar@trantorinc.com", "kirandeep.kaur@trantorinc.com", "ankur.bhardwaj@trantorinc.com"]
  EMAILNOTIFYMAIN = ["rajat.julka@trantorinc.com", "raj.kondal@trantorinc.com", "pradeep@trantorinc.com", "sriram@trantorinc.com"]

  has_many :projects, :inverse_of => :user
end