module Api
  class MailersController < ApplicationController
  	http_basic_authenticate_with name: "admin", password: "password"
  	respond_to :json

  	def send_mail
  		case request.format
    	when Mime::XML, Mime::ATOM, Mime::JSON
			 render json: {:status => 'failed'}
    	end
    	
  	end

  end
end  