class Api::ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception
  
  rescue_from Mongoid::Errors::DocumentNotFound, with: :record_not_found
  rescue_from Mongoid::Errors::Validations, with: :invalid_request
  #rescue_from Exceptions::Standard, with: :custom_api_error
  
  respond_to :json

  def record_not_found
    error(status: :not_found, message: "URL does not represent a resource")
  end
  
  def invalid_request
    error(status: :bad_request, message: "The request is badly formatted")
  end
  
  def custom_api_error
    error(status: :bad_request, message: "")
  end
    
  def error(status: :bad_request, message: nil)
    render 'api/v1/shared/error', locals: {status: status, message: message}
  end
    
  
    
end
