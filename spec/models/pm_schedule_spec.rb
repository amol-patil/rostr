require 'rails_helper'

describe PmSchedule do
  describe "#callback_slack" do
    before do
      allow(Thread).to receive(:new).and_yield
    end    

    subject { PmSchedule.new("test_response_url").callback_slack }

    context "non-transition day" do
      let(:request_body) { {"text" => "PM primary on-call is: LME\nPM secondary on-call is: HEK"} }
      let(:request_body_error) { {"text" => "Schedule not set for today"} }
     
      it "returns the PM for the day" do
        Timecop.freeze(Time.local(2016, 2, 7, 9))
        VCR.use_cassette("google_spreadsheet_pm") do
          expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body.to_json)
          subject
        end
      end

      it "returns error message when schedule not set" do
        Timecop.freeze(Time.local(2018, 2, 7, 9))
        VCR.use_cassette("google_spreadsheet_pm") do
          expect(HTTParty).to receive(:post).with("test_response_url", :body => request_body_error.to_json)
          subject
        end 
      end
    end

    context "transition day" do
      let(:request_body_before_10) { {"text" => "PM primary on-call is: MSG\nPM secondary on-call is: CKS"} }
      let(:request_body_after_10) { {"text" => "PM primary on-call is: MSG\nPM secondary on-call is: MKT"} }

      it "returns the day before if before 10a" do
        Timecop.freeze(Time.local(2016, 3, 7, 9))
        VCR.use_cassette("google_spreadsheet_pm") do
          expect(HTTParty).to receive(:post)
                          .with("test_response_url", :body => request_body_before_10.to_json)
          subject
        end
      end

      it "returns current day if after 10a" do
        Timecop.freeze(Time.local(2016, 3, 7, 11))
        VCR.use_cassette("google_spreadsheet_pm") do
          expect(HTTParty).to receive(:post)
                        .with("test_response_url", :body => request_body_after_10.to_json)
          subject
        end
      end
    end
  end
end