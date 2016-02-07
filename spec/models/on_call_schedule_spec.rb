require 'rails_helper'
require 'vcr'
require 'json'

describe OnCallSchedule do

  describe "#is_team_name_valid?" do

    it "matches if team name is within the list" do
      expect(OnCallSchedule.new("CS", "test_response_url").is_team_name_valid?).to eq(true)
    end

    it "returns command not found when name not within the list" do
      expect(OnCallSchedule.new("MI", "test_response_url").is_team_name_valid?).to eq(false)
    end
  end

  describe "#callback_slack" do

    before do
      allow(Thread).to receive(:new).and_yield
    end

    context "CS" do
      subject { OnCallSchedule.new("CS", "test_response_url").callback_slack }

      context "when non-transition day" do
        let(:request_body) { {"text" => "CS on-call is: RL"} }
        let(:request_body_override) { {"text" => "CS on-call is: JDD"} }
        let(:request_body_error) { {"text" => "Schedule not set for today"} }

        it "returns corresponding row for the date" do
          Timecop.freeze(Time.local(2016, 2, 7, 9))
          VCR.use_cassette("google_spreadsheet") do
            expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body.to_json)
            subject
          end
        end

        it "returns error message when date not present" do
          Timecop.freeze(Time.local(2017, 1, 1, 1))
          VCR.use_cassette("google_spreadsheet") do
            expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body_error.to_json)
            subject
          end
        end

        it "returns override when specified" do
          Timecop.freeze(Time.local(2015, 11, 6, 11))
          VCR.use_cassette("google_spreadsheet") do
            expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body_override.to_json)
            subject
          end
        end

        it "returns row ignoring cases for team name" do
          Timecop.freeze(Time.local(2016, 2, 7, 9))
          VCR.use_cassette("google_spreadsheet") do
            expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body.to_json)
            OnCallSchedule.new("cS", "test_response_url").callback_slack
          end
        end
      end

      context "when transition day" do
        let(:request_body_before_10) { {"text" => "CS on-call is: PAA"} }
        let(:request_body_after_10) { {"text" => "CS on-call is: RL"} }

        it "returns the day before if before 10a" do
          Timecop.freeze(Time.local(2016, 2, 5, 9))
          VCR.use_cassette("google_spreadsheet") do
            expect(HTTParty).to receive(:post)
                            .with("test_response_url", :body => request_body_before_10.to_json)
            subject
          end
        end

        it "returns current day if after 10a" do
          Timecop.freeze(Time.local(2016, 2, 5, 11))
          VCR.use_cassette("google_spreadsheet") do
            expect(HTTParty).to receive(:post)
                          .with("test_response_url", :body => request_body_after_10.to_json)
            subject
          end
        end
      end
    end

    context "CA" do
      subject { OnCallSchedule.new("CA", "test_response_url").callback_slack }

      context "when non-transition day" do
        let(:request_body) { {"text" => "CA on-call is: BCY"} }
        let(:request_body_UW) { {"text" => "UW on-call is: BCY"} }
        let(:request_body_override) { {"text" => "CA on-call is: CAR"} }
        let(:request_body_error) { {"text" => "Schedule not set for today"} }

        it "returns corresponding row for the date" do
          Timecop.freeze(Time.local(2016, 2, 7, 9))
          VCR.use_cassette("google_spreadsheet") do
            expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body.to_json)
            subject
          end
        end

        it "returns override when specified" do
          Timecop.freeze(Time.local(2015, 11, 13, 11))
          VCR.use_cassette("google_spreadsheet") do
            expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body_override.to_json)
            subject
          end
        end

        it "returns error message when date not present" do
          Timecop.freeze(Time.local(2017, 1, 1, 1))
          VCR.use_cassette("google_spreadsheet") do
            expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body_error.to_json)
            subject
          end
        end

        it "returns same schedule for UW" do
          Timecop.freeze(Time.local(2016, 2, 7, 9))
          VCR.use_cassette("google_spreadsheet") do
            expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body_UW.to_json)
            OnCallSchedule.new("UW", "test_response_url").callback_slack
          end
        end
      end

      context "when transition day" do
        let(:request_body_before_10) { {"text" => "CA on-call is: CK"} }
        let(:request_body_after_10) { {"text" => "CA on-call is: BCY"} }

        it "returns the day before if before 10a" do
          Timecop.freeze(Time.local(2016, 2, 5, 9))
          VCR.use_cassette("google_spreadsheet") do
            expect(HTTParty).to receive(:post)
                            .with("test_response_url", :body => request_body_before_10.to_json)
            subject
          end
        end

        it "returns current day if after 10a" do
          Timecop.freeze(Time.local(2016, 2, 5, 11))
          VCR.use_cassette("google_spreadsheet") do
            expect(HTTParty).to receive(:post)
                          .with("test_response_url", :body => request_body_after_10.to_json)
            subject
          end
        end
      end
    end

    context "ROID" do
      subject { OnCallSchedule.new("ROID", "test_response_url").callback_slack }

      context "when non-transition day" do
        let(:request_body) { {"text" => "ROID on-call is: CHH"} }
        let(:request_body_override) { {"text" => "ROID on-call is: JDD"} }
        let(:request_body_error) { {"text" => "Schedule not set for today"} }

        it "returns corresponding row for the date" do
          Timecop.freeze(Time.local(2016, 2, 7, 9))
          VCR.use_cassette("google_spreadsheet") do
            expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body.to_json)
            subject
          end
        end

        it "returns override when specified" do
          Timecop.freeze(Time.local(2015, 11, 6, 11))
          VCR.use_cassette("google_spreadsheet") do
            expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body_override.to_json)
            subject
          end
        end

        it "returns error message when date not present" do
          Timecop.freeze(Time.local(2017, 1, 1, 1))
          VCR.use_cassette("google_spreadsheet") do
            expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body_error.to_json)
            subject
          end
        end
      end

      context "when transition day" do
        let(:request_body_before_10) { {"text" => "ROID on-call is: VNC"} }
        let(:request_body_after_10) { {"text" => "ROID on-call is: CHH"} }

        it "returns the day before if before 10a" do
          Timecop.freeze(Time.local(2016, 2, 5, 9))
          VCR.use_cassette("google_spreadsheet") do
            expect(HTTParty).to receive(:post)
                            .with("test_response_url", :body => request_body_before_10.to_json)
            subject
          end
        end

        it "returns current day if after 10a" do
          Timecop.freeze(Time.local(2016, 2, 5, 11))
          VCR.use_cassette("google_spreadsheet") do
            expect(HTTParty).to receive(:post)
                          .with("test_response_url", :body => request_body_after_10.to_json)
            subject
          end
        end
      end
    end
  end 
  
end