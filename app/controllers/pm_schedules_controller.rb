class PmSchedulesController < ApplicationController
  
  def create
    pm = PmSchedule.new(params[:response_url])
    respond_to do |format|
      format.json { render "create", :status => :ok }
      pm.callback_slack
    end
  end
end