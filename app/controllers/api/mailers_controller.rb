module Api
  class MailersController < ApplicationController
  	http_basic_authenticate_with name: "admin", password: "password"
    after_filter :send_thirdparty_mail
  	respond_to :json

  	def send_mail
  		case request.format
    	when Mime::XML, Mime::ATOM, Mime::JSON
			 render json: {:status => 'ok'}
    	end
  	end


    def send_thirdparty_mail
      UserNotifier.send_mobile_notification_mail(params[:header], params[:body]).deliver!
    end  

  end
end  