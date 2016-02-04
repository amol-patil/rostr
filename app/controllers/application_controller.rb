class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
 
  # Slack requests define Accept-Type as HTML 
  # but we want to render JSON template. This
  # is to override all incoming requests and 
  # treat them as JSON
  before_filter :set_json_format

  def set_json_format
    request.format = :json
  end
end
