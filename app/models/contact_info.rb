require 'google_drive'
require 'google/api_client'
require 'json'
require 'httparty'

class ContactInfo

  attr_accessor :name, :response_url, :first_names, :last_names, :user_names

  def initialize(name, response_url)
    @name = name
    @response_url = response_url
    @first_names = []
    @last_names = []
    @user_names = []
  end

  def is_name_valid?
    return is_first_name_valid? && is_last_name_valid? && is_user_name_valid?
  end

  def is_first_name_valid?
    # return ["Sean"].include?(name) ? true : false
    return true
  end

  def is_last_name_valid?
    return ["Kamkar"].include?(name) ? true : false
  end

  def is_user_name_valid?
    return ["sjk"].include?(name) ? true : false
  end

  def callback_slack
    Thread.new do
      rows = find_contact_rows(name, get_spreadsheet)
      if !rows.empty?
        # matching_users = pull_matching_users(rows)
        if rows.length == 1
          request_body = {"text" => "One user exists!" }
        else
          request_body = {"text" => "#{rows.length} users exist!" }
        end
      else
        request_body = {"text" => "#{name} does not exist :(" }
      end
      HTTParty.post(response_url, body: request_body.to_json)
    end
  end

  def get_spreadsheet
    session = GoogleDrive.saved_session("config.json")
    session.spreadsheet_by_key("1BO-QOC-r748Y0t1lodc0BrBN2U3xA55YNY67cb09i-8").worksheets[0]
  end

  def find_contact_rows(name, worksheet)
    row = []
    (2..worksheet.rows.size-1).each do |i|
      full_name = worksheet["A#{i}"].downcase
      email = worksheet["B#{i}"].downcase
      if full_name.include?(name.downcase)
        row << i
      elsif email.include?(name.downcase)
        row << i
      end
    end
    row
  end

end