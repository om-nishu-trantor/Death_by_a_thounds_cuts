class WebRead < ParseResource::Base
	fields :user_id, :issues_id
	belongs_to :user, :class_name => 'User'
	belongs_to :issues, :class_name => 'Issue'
end	