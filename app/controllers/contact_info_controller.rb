class ContactInfoController < ApplicationController

  def create
    contact_info = ContactInfo.new(params[:text], params[:response_url])
    respond_to do |format|

      if contact_info.is_name_valid?
        format.json { render "create", :status => :ok }
        contact_info.callback_slack
      # elsif contact_info.is_last_name_valid?
      #   format.json { render "create", :status => :ok }
      #   contact_info.callback_slack
      # elsif contact_info.is_user_name_valid?
      #   format.json { render "create", :status => :ok }
      #   contact_info.callback_slack
      else
        format.json { render "create_error", :status => :unprocessable_entity}
      end
    end
  end
end
