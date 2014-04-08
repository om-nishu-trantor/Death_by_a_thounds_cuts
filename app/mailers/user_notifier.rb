class UserNotifier < ActionMailer::Base
  include ActionView::Helpers::TextHelper
  default from: "noreply@deathbyadousandcuts.com"
  
  # layout 'email'

  def send_create_notification_mail object
    setup_mail object, "DBTC: #{object.Project} cut created: "+truncate(object.Description, length: 25)
  end

  def send_update_notification_mail object
    setup_mail object, "DBTC: #{object.Project} cut updated: "+truncate(object.Description, length: 25)
  end

  def send_delete_notification_mail object
    setup_mail object, "DBTC: #{object.Project} cut deleted: "+truncate(object.Description, length: 25)
  end

  def send_close_notification_mail object
    setup_mail object, "DBTC: #{object.Project} cut fixed: "+truncate(object.Description, length: 25)
  end

  def send_mobile_notification_mail header, body
    @body_data = body
    mail(:to => (User::EMAILNOTIFYTEST).join(',') , :subject => header )
  end
  def setup_mail object, sub
    @object_data = object
    mail(:to => (User::EMAILNOTIFYTEST).join(',') , :subject => sub )
  end  


end