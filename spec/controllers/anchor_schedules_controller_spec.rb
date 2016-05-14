require 'rails_helper'

describe AnchorSchedulesController do 
  context "POST" do
    context "200" do
      let(:params) { {"text" => "UW"} } 
      it "returns 200 with valid params" do
        post :create, params
        expect(response.status).to eq(200)
      end
      it "renders create template" do
        post :create, params
        expect(response).to render_template("create")
      end

      it "calls back slack after rendering" do
        expect_any_instance_of(AnchorSchedule).to receive(:callback_slack)
        post :create, params
      end
    end

    context "422" do
      let(:params) { {"text" => "Slack test"} }
      it "returns 422 with invalid params" do
        post :create, params
        expect(response.status).to eq(422)
      end

      it "renders error template" do
        post :create, params
        expect(response).to render_template("create_error")
      end
    end
  end
end