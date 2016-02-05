require 'byebug'
require 'google_drive'
require 'google/api_client'

class SchedulesController < ApplicationController

  def create
    @team = params[:text]
    respond_to do |format|
      if is_team_name_valid?(@team)
        final_row = extract_final_row(@team, get_spreadsheet)
        @oncall = whos_on_call(@team, final_row)
        format.json { render "create", :status => :ok}
      else 
        format.json { render "create_error", :status => :unprocessable_entity}
      end 
    end
  end

  def is_team_name_valid?(team_name)
    team_names = ["ROID", "CA", "CS"]
    return team_names.include?(team_name.try(:upcase)) ? true : false
  end

  def get_spreadsheet
    session = GoogleDrive.saved_session("config.json")
    session.spreadsheet_by_key("1_WVfnRMINBfH6NSUZ6XQh2QCoR7Eu1P_3tlLS8_PlLQ").worksheets[0]
  end

  def extract_final_row(team, worksheet)
    (3..worksheet.rows.size-1).each do |i|
      next_num = i+1
      current_time_slot = Date.strptime(worksheet["A#{i}"],"%m/%d/%Y")
      next_time_slot = Date.strptime(worksheet["A#{next_num}"],"%m/%d/%Y")
      if Time.now.between?(current_time_slot, next_time_slot)
        return Time.now.hour < 10 ? worksheet.rows[i-1] : worksheet.rows[i]
      end
    end
  end

  def whos_on_call(team, final_row)
    case team
    when "CA"
      return final_row[4] == "" ? final_row[3] : final_row[4]
    when "CS"
      return final_row[8] == "" ? final_row[7] : final_row[8]
    when "ROID"
      return final_row[2] == "" ? final_row[1] : final_row[2]
    else
      return "ERROR"
    end  
  end
end