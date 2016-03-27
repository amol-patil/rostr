require 'byebug'

class AnchorSchedulesController < ApplicationController
  
  def create
    anchor = AnchorSchedule.new(params[:text], params[:response_url])
    respond_to do |format|
      if anchor.is_team_name_valid? 
        format.json { render "create", :status => :ok}
        anchor.callback_slack
      else 
        format.json { render "create_error", :status => :unprocessable_entity }
      end
    end
  end

end