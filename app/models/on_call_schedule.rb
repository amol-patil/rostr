require 'google_drive'
require 'google/api_client'
require 'json'
require 'httparty'

class OnCallSchedule

  attr_accessor :team, :response_url 

  def initialize(team, response_url)
    @team = team.try(:upcase)
    @response_url = response_url
  end

  def is_team_name_valid?
    team_names = ["CA", "CS", "UW"]
    return team_names.include?(team) ? true : false
  end

  def callback_slack
    Thread.new do
      final_row = extract_final_row(team, get_spreadsheet)
      if final_row.empty?
        request_body = {"text" => "Schedule not set for today" }
      else 
        oncall = whos_on_call(team, final_row)
        request_body = {"text" => team + " primary on-call is: " + oncall[0].upcase + "\n" + team + " secondary on-call is: " + oncall[1].upcase }
      end
      HTTParty.post(response_url, body: request_body.to_json)
    end
  end
  
  private 

  def whos_on_call(team, final_row)
    oncall = []
    case team
    when "CA", "UW"
      final_row[2] == "" ? oncall[0] = final_row[1] : oncall[0] = final_row[2]
      final_row[6] == "" ? oncall[1] = final_row[5] : oncall[0] = final_row[6]
      return oncall
    when "CS"
      final_row[4] == "" ? oncall[0] = final_row[3] : oncall[0] = final_row[4]
      final_row[8] == "" ? oncall[1] = final_row[7] : oncall[0] = final_row[8] 
      return oncall
    else
      return "ERROR"
    end  
  end

  def get_spreadsheet
    session = GoogleDrive.saved_session("config.json")
    session.spreadsheet_by_key("16oc-tznFkwVPASk-5-BEa8zhV2dkbgP6CJAEZQl_ecw").worksheets[0]
  end

  def extract_final_row(team, worksheet)
    row = []
    (2..worksheet.rows.size-1).each do |i|
      next_num = i+1
      current_date = Date.strptime(worksheet["A#{i}"],"%m/%d/%Y")
      next_date = Date.strptime(worksheet["A#{next_num}"],"%m/%d/%Y")
      if Date.today == current_date
        row = Time.now.hour < 10 ? worksheet.rows[i-2] : worksheet.rows[i-1]
      elsif Date.today.between?(current_date, next_date)
        row = worksheet.rows[i-1]
      end
    end
    row
  end

end