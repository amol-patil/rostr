class PmSchedule

  attr_accessor :response_url

  def initialize(response_url)
    @response_url = response_url
  end

  def callback_slack
    Thread.new do
      final_row = extract_final_row(get_spreadsheet)
      if final_row.empty?
        request_body = {"text" => "Schedule not set for today"}
      else
        request_body = {"text" => "PM primary on-call is: " + final_row[1].upcase + "\n" + "PM secondary on-call is: " + final_row[2].upcase}
      end
      HTTParty.post(response_url, body: request_body.to_json)
    end
  end

  private

  def get_spreadsheet
    session = GoogleDrive.saved_session("config.json")
    session.spreadsheet_by_key("1POi64waA7VMHLkkqTFCUO40Ipvky6JbaxCEIsFMYGSM").worksheets[1]
  end

  def extract_final_row(worksheet)
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