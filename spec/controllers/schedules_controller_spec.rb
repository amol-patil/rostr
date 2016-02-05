require 'rails_helper'

describe SchedulesController do
  context "POST" do
    let(:params) { "Slack Test" }
    let(:valid_params) { {"text" => "CS"} }

    context "422" do
      it "returns 422 with invalid param" do
        post :create
        expect(response.status).to be(422)
      end

      it "renders error template for invalid params" do
        post :create
        expect(response).to render_template("create_error")
      end
    end

    context "200" do
      it "returns 200 with valid params" do
        post :create, valid_params
        expect(response.status).to be(200)
      end

      it "renders create template for valid params" do
        post :create, valid_params
        expect(response).to render_template("create")
      end
    end
  end

  context "teams" do
    it "matches if team name is within the list" do
      expect(SchedulesController.new.is_team_name_valid?("CA")).to eq(true)
    end

    it "returns command not found when name not within the list" do
      expect(SchedulesController.new.is_team_name_valid?("MI")).to eq(false)
    end
  end
  
  context "whosoncall" do
    let(:row_simple) { ["01/01/2016", "test", "", "ca-test", "", "ca-test", "", "cs-test", "", "cs-test", ""] }
    let(:row_override) { ["01/01/2016", "test", "test-override", "ca-test", "ca-override", "ca-test", "", "cs-test", "", "cs-test", "cs-override"] }

    it "returns first on call when no overrides" do
      expect(SchedulesController.new.whos_on_call("CS", row_simple)).to eq("cs-test")
    end

    it "returns override on call when override is specified" do
      expect(SchedulesController.new.whos_on_call("ROID", row_override)).to eq("test-override")
    end

    it "returns error on non matching team name" do
      expect(SchedulesController.new.whos_on_call("UW", row_simple)).to eq("ERROR")
    end

    skip "returns current row on transition day before 10a" do
    end
    
    skip "returns next row on transition day after 10a" do
    end

  end

  context "Gdrive credentials setup" do
    it "looks for saved config file" do
      mock_session = double("session")
      allow(GoogleDrive).to receive(:saved_session).with(anything()) { mock_session }
      allow(mock_session).to receive_message_chain(:spreadsheet_by_key, :worksheets => ["spreadsheet"])
      expect(SchedulesController.new.get_spreadsheet).to eq("spreadsheet")
    end
  end

  context "extract final row" do
    skip "tests final row extraction" do
    end
  end

end