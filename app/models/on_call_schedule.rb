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
    session.spreadsheet_by_key("1h71PBoL_nz2_3fJZ2DH3xRmG-oY820mY7iur9p3Hxao").worksheets[0]
  end

  def extract_final_row(team, worksheet)
    sanitized_worksheet = sanitize_worksheet_array(worksheet)
    row = []
    sanitized_worksheet.each_with_index do |record, index|
      current_date = Date.strptime(record.first,"%m/%d/%Y")
      if current_date > Date.today
        return row = index == 0 ? [] : sanitized_worksheet[index-1]
      end
      if current_date == Date.today
        return row = Time.now.hour < 10 ? sanitized_worksheet[index-1] : record unless index == 0
      end
    end
  end

  def sanitize_worksheet_array(worksheet)
    sanitized_worksheet = []
    (3..worksheet.rows.size-1).each do |record|
      begin
        if Date.strptime(worksheet["A#{record}"],"%m/%d/%Y")
          sanitized_worksheet << worksheet.rows[record-1]
        end
      rescue
        next
      end
    end
    sanitized_worksheet
  end

end