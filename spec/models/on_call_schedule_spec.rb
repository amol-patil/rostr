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
        let(:request_body) { {"text" => "CS primary on-call is: CGJ\nCS secondary on-call is: KBJ" } }
        let(:request_body_override) { {"text" => "CS primary on-call is: TEST\nCS secondary on-call is: KBJ" } }
        let(:request_body_error) { {"text" => "Schedule not set for today"} }

        it "returns corresponding row for the date" do
          Timecop.freeze(Time.local(2016, 3, 8, 9))
          VCR.use_cassette("google_spreadsheet_two_tier") do
            expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body.to_json)
            subject
          end
        end

        it "returns error message when date not present" do
          Timecop.freeze(Time.local(2011, 1, 1, 1))
          VCR.use_cassette("google_spreadsheet_two_tier") do
            expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body_error.to_json)
            subject
          end
        end

        it "returns override when specified" do
          Timecop.freeze(Time.local(2016, 2, 13, 23, 59))
          VCR.use_cassette("google_spreadsheet_two_tier") do
            expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body_override.to_json)
            subject
          end
        end

        it "returns row ignoring cases for team name" do
          Timecop.freeze(Time.local(2016, 3, 8, 9))
          VCR.use_cassette("google_spreadsheet_two_tier") do
            expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body.to_json)
            OnCallSchedule.new("cS", "test_response_url").callback_slack
          end
        end
      end

      context "when transition day" do
        let(:request_body_before_10) { {"text" => "CS primary on-call is: TEST\nCS secondary on-call is: KBJ"} }
        let(:request_body_after_10) { {"text" => "CS primary on-call is: JMC\nCS secondary on-call is: JDD"} }

        it "returns the day before if before 10a" do
          Timecop.freeze(Time.local(2016, 2, 14, 9))
          VCR.use_cassette("google_spreadsheet_two_tier") do
            expect(HTTParty).to receive(:post)
                            .with("test_response_url", :body => request_body_before_10.to_json)
            subject
          end
        end

        it "returns current day if after 10a" do
          Timecop.freeze(Time.local(2016, 2, 14, 11))
          VCR.use_cassette("google_spreadsheet_two_tier") do
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
        let(:request_body) { {"text" => "CA primary on-call is: RL\nCA secondary on-call is: KJU" } }
        let(:request_body_UW) { {"text" => "UW primary on-call is: RL\nUW secondary on-call is: KJU" } }
        let(:request_body_override) { {"text" => "CA primary on-call is: CAR\nCA secondary on-call is: RL" } }
        let(:request_body_error) { {"text" => "Schedule not set for today"} }

        it "returns corresponding row for the date" do
          Timecop.freeze(Time.local(2016, 3, 8, 9))
          VCR.use_cassette("google_spreadsheet_two_tier") do
            expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body.to_json)
            subject
          end
        end

        it "returns error message when date not present" do
          Timecop.freeze(Time.local(2011, 1, 1, 1))
          VCR.use_cassette("google_spreadsheet_two_tier") do
            expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body_error.to_json)
            subject
          end
        end

        it "returns override when specified" do
          Timecop.freeze(Time.local(2016, 2, 13, 23, 59))
          VCR.use_cassette("google_spreadsheet_two_tier") do
            expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body_override.to_json)
            subject
          end
        end

        it "returns row ignoring cases for team name" do
          Timecop.freeze(Time.local(2016, 3, 8, 9))
          VCR.use_cassette("google_spreadsheet_two_tier") do
            expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body.to_json)
            OnCallSchedule.new("cA", "test_response_url").callback_slack
          end
        end

        it "returns same results for CA/UW " do
          Timecop.freeze(Time.local(2016, 3, 8, 9))
          VCR.use_cassette("google_spreadsheet_two_tier") do
            expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body_UW.to_json)
            OnCallSchedule.new("UW", "test_response_url").callback_slack
          end
        end
      end

      context "when transition day" do
        let(:request_body_before_10) { {"text" => "CA primary on-call is: CAR\nCA secondary on-call is: RL"} }
        let(:request_body_after_10) { {"text" => "CA primary on-call is: KGH\nCA secondary on-call is: CAR"} }

        it "returns the day before if before 10a" do
          Timecop.freeze(Time.local(2016, 2, 14, 9))
          VCR.use_cassette("google_spreadsheet_two_tier") do
            expect(HTTParty).to receive(:post)
                            .with("test_response_url", :body => request_body_before_10.to_json)
            subject
          end
        end

        it "returns current day if after 10a" do
          Timecop.freeze(Time.local(2016, 2, 14, 11))
          VCR.use_cassette("google_spreadsheet_two_tier") do
            expect(HTTParty).to receive(:post)
                          .with("test_response_url", :body => request_body_after_10.to_json)
            subject
          end
        end
      end
    end 
  end 
  
end