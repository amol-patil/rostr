require 'rails_helper'
require 'vcr'
require 'json'

describe ContactInfo do

  describe "#is_name_valid?" do
    it "returns false if name is invalid" do
      expect(ContactInfo.new("8-,7hj", "test_response_url").is_name_valid?).to eq(false)
    end

    it "returns true if name is valid" do
      expect(ContactInfo.new("peter", "test_response_url").is_name_valid?).to eq(true)
    end

    it "does not allow white space" do
      expect(ContactInfo.new("peter griffin", "test_response_url").is_name_valid?).to eq(false)
    end
  end

  describe "#callback_slack" do
    before do
      allow(Thread).to receive(:new).and_yield
    end

    context "one user matches" do
      subject { ContactInfo.new("Sean", "test_response_url").callback_slack }
      let(:request_body) { File.read("./fixtures/contact_sean.txt") }

      it "returns info for single user" do
        Timecop.freeze(Time.local(2016, 5, 23))
        VCR.use_cassette("google_spreadsheet_contact") do
          expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body)
          subject
        end
      end
    end

    context "multiple users match" do
      subject { ContactInfo.new("Mike", "test_response_url").callback_slack }
      let(:request_body) { File.read("./fixtures/contact_mike.txt") }

      it "returns info for multiple users" do
        Timecop.freeze(Time.local(2016, 5, 23))
        VCR.use_cassette("google_spreadsheet_contact") do
          expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body)
          subject
        end
      end
    end

    context "no users match" do
      subject { ContactInfo.new(missing_user, "test_response_url").callback_slack }

      let(:missing_user) {"Breiman"}
      let(:request_body_error) { {"text" => "#{missing_user} could not be found :("} }

      it "returns error" do
        Timecop.freeze(Time.local(2016, 5, 23))
        VCR.use_cassette("google_spreadsheet_contact") do
          expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body_error.to_json)
          subject
        end
      end
    end
  end

end