class UserNotifier < ActionMailer::Base
  
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

  def setup_mail mail_to, object, sub
    @mail_to = mail_to
    @object = object
    mail(:to => mail_to , :subject => sub )
  end  


end