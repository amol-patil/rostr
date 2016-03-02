require 'rails_helper'

describe PmSchedulesController do
  context "POST" do
    context "200" do
      it "returns a 200" do
        post :create 
        expect(response.status).to eq (200)
      end

      it "renders create template" do
        post :create
        expect(response).to render_template("create")
      end

      it "callsback slack after rendering" do
        expect_any_instance_of(PmSchedule).to receive(:callback_slack)
        post :create
      end
    end
  end
end