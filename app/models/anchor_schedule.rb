require 'google_drive'
require 'google/api_client'
require 'json'
require 'httparty'

class AnchorSchedule 

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
      row = find_row(team, get_spreadsheet)
      if row.empty?
        request_body = {"text" => "Schedule not set for today" }
      else 
        anchor = whos_anchor(team, row)
        request_body = {"text" => team + " anchor is: " + anchor.upcase}
      end
      HTTParty.post(response_url, body: request_body.to_json)
    end
  end

  private

  def get_spreadsheet
    session = GoogleDrive.saved_session("config.json")
    session.spreadsheet_by_key("1h71PBoL_nz2_3fJZ2DH3xRmG-oY820mY7iur9p3Hxao").worksheets[2]
  end

  def whos_anchor(team, row)
    case team
    when "CA"
      return row[1]
    when "CS"
      return row[2]
    when "UW"
      return row[3]
    else
      return "ERROR"
    end  
  end

  def find_row(team, worksheet)
    row = []
    (2..worksheet.rows.size-1).each do |i|
      next_num = i+1
      current_date = Date.strptime(worksheet["A#{i}"],"%m/%d/%Y")
      next_date = Date.strptime(worksheet["A#{next_num}"],"%m/%d/%Y")
      if Date.today.between?(current_date, next_date)
        row = worksheet.rows[i-1]
      end
    end
    row
  end

end