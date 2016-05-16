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
    return true
  end

  def callback_slack
    Thread.new do
      contacts = pull_contact_data(name, get_spreadsheet)
      if !contacts.empty?
        prepend_contacts = preprend_body(contacts).join("\n")
        request_body = {"text" => prepend_contacts }
      else
        request_body = {"text" => "#{name} could not be found :(" }
      end
      HTTParty.post(response_url, body: request_body.to_json)
    end
  end

  def preprend_body(body)
    full_body = []
    if body.length == 1
      full_body << "1 user found\n\n"
    else
      full_body << "#{body.length} users found\n\n"
    end
    full_body << body
  end

  def get_spreadsheet
    session = GoogleDrive.saved_session("config.json")
    session.spreadsheet_by_key("1BO-QOC-r748Y0t1lodc0BrBN2U3xA55YNY67cb09i-8").worksheets[0]
  end

  def pull_contact_data(name, worksheet)
    body = []
    rows = []
    (2..worksheet.rows.size-1).each do |i|
      full_name = worksheet["A#{i}"].downcase
      email = worksheet["B#{i}"].downcase
      if full_name.include?(name.downcase)
        rows << i
      elsif email.include?(name.downcase)
        rows << i
      end
    end

    rows.each do |row|
      body << [
        "- - - - - - - - - - - - - - - - \n",
        "name: \t#{worksheet["A#{row}"]} \n",
        "email: \t#{worksheet["B#{row}"]} \n",
        "office: \t#{worksheet["C#{row}"]} \n",
        "cell:\t\t#{worksheet["D#{row}"]} \n",
        "group: \t#{worksheet["E#{row}"]} \n"
      ].join()
    end
    body
  end

end