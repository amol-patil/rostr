require 'rails_helper'

describe SchedulesController do
  context "POST" do
    let(:params) { "Slack Test" }
    let(:valid_params) { {"text" => "UW"} }

    context "422" do
      it "returns 422" do
        post :create
        expect(response.status).to be(422)
      end

      it "renders error template" do
        post :create
        expect(response).to render_template("create_error")
      end
    end

    context "200" do
      it "returns 200" do
        post :create, valid_params
        expect(response.status).to be(200)
      end

      it "renders create template" do
        post :create, valid_params
        expect(response).to render_template("create")
      end
    end

  end

  context "finds respective team" do
    it "matches if team name is within the list" do
      expect(SchedulesController.new.is_team_name_valid?("CA")).to eq(true)
    end

    it "returns command not found when name not within the list" do
      expect(SchedulesController.new.is_team_name_valid?("MI")).to eq(false)
    end
  end
end