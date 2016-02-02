require 'byebug'

class SchedulesController < ApplicationController

  def create
    team = params[:text]
    respond_to do |format|
      if is_team_name_valid?(team)
        format.json { render "create", :status => :ok}
      else 
        format.json { render "create_error", :status => :unprocessable_entity}
      end 
    end
  end

  def is_team_name_valid?(team_name)
    team_names = ["CA", "CS", "UW"]
    return team_names.include?(team_name.try(:upcase)) ? true : false
  end

end