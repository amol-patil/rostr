require 'rails_helper'
require 'vcr'
require 'json'

describe AnchorSchedule do
  describe "#is_team_name_valid?" do
    it "matches for valid team name" do
      expect(AnchorSchedule.new("UW", "test_response_url").is_team_name_valid?).to eq(true)
    end

    it "does not match invalid team name" do
      expect(AnchorSchedule.new("MI", "test_response_url").is_team_name_valid?).to eq(false)
    end
  end

  describe "#callback_slack" do
    before do
      allow(Thread).to receive(:new).and_yield
    end

    context "CS" do
      subject { AnchorSchedule.new("CS", "test_response_url").callback_slack }

      let(:request_body) { {"text" => "CS anchor is: CGJ"} }
      let(:request_body_error) { {"text" => "Schedule not set for today"} }

      it "returns corresponding row for matching day" do
        Timecop.freeze(Time.local(2016, 2, 8))
        VCR.use_cassette("google_spreadsheet_anchor") do
          expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body.to_json)
          subject
        end
      end

      it "returns corresponding slot date that falls in range" do
        Timecop.freeze(Time.local(2016, 2, 9))
        VCR.use_cassette("google_spreadsheet_anchor") do
          expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body.to_json)
          subject
        end
      end

      it "returns schedule not set when date not in range" do
        Timecop.freeze(Time.local(2018, 2, 9))
        VCR.use_cassette("google_spreadsheet_anchor") do
          expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body_error.to_json)
          subject
        end
      end
    end

    context "CA" do
      subject { AnchorSchedule.new("CA", "test_response_url").callback_slack }

      let(:request_body) { {"text" => "CA anchor is: RL"} }
      let(:request_body_error) { {"text" => "Schedule not set for today"} }

      it "returns corresponding row for matching day" do
        Timecop.freeze(Time.local(2016, 2, 8))
        VCR.use_cassette("google_spreadsheet_anchor") do
          expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body.to_json)
          subject
        end
      end

      it "returns corresponding slot date that falls in range" do
        Timecop.freeze(Time.local(2016, 2, 9))
        VCR.use_cassette("google_spreadsheet_anchor") do
          expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body.to_json)
          subject
        end
      end

      it "returns schedule not set when date not in range" do
        Timecop.freeze(Time.local(2018, 2, 9))
        VCR.use_cassette("google_spreadsheet_anchor") do
          expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body_error.to_json)
          subject
        end
      end
    end

    context "UW" do
      subject { AnchorSchedule.new("UW", "test_response_url").callback_slack }

      let(:request_body) { {"text" => "UW anchor is: SJK"} }
      let(:request_body_error) { {"text" => "Schedule not set for today"} }

      it "returns corresponding row for matching day" do
        Timecop.freeze(Time.local(2016, 2, 8))
        VCR.use_cassette("google_spreadsheet_anchor") do
          expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body.to_json)
          subject
        end
      end

      it "returns corresponding slot date that falls in range" do
        Timecop.freeze(Time.local(2016, 2, 9))
        VCR.use_cassette("google_spreadsheet_anchor") do
          expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body.to_json)
          subject
        end
      end
      
      it "returns schedule not set when date not in range" do
        Timecop.freeze(Time.local(2018, 2, 9))
        VCR.use_cassette("google_spreadsheet_anchor") do
          expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body_error.to_json)
          subject
        end
      end
    end
  end
end