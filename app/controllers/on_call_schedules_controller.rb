class OnCallSchedulesController < ApplicationController

  def create
    on_call = OnCallSchedule.new(params[:text], params[:response_url])
    respond_to do |format|
      if on_call.is_team_name_valid?
        format.json { render "create", :status => :ok }
        on_call.callback_slack
      else 
        format.json { render "create_error", :status => :unprocessable_entity}
      end
    end
  end
end