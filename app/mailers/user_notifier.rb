class UserNotifier < ActionMailer::Base
  include ActionView::Helpers::TextHelper
  default from: "noreply@deathbyadousandcuts.com"
  
  # layout 'email'

  def send_create_notification_mail mail_to, object
    setup_mail mail_to, object, "New Issue"
  end

  def send_update_notification_mail mail_to, object
    setup_mail mail_to, object, "Issue Update"
  end

  def send_delete_notification_mail mail_to, object
    setup_mail mail_to, object, "Issue Deleted"
  end

  def send_close_notification_mail object
    setup_mail object
  end

  def send_mobile_notification_mail header, body
    @body_data = body
    mail(:to => (User::EMAILNOTIFYTEST).join(',') , :subject => header )
  end
  def setup_mail object 
    @object_data = object
    mail(:to => (User::EMAILNOTIFYTEST).join(',') , :subject => "DBTC: #{object.Project} cut fixed: "+truncate(object.Description, length: 25)  )
  end  


end