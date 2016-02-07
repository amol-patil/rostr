require 'rails_helper'

describe OnCallSchedulesController do
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

      it "calls callback_slack after rendering create" do
        expect_any_instance_of(OnCallSchedule).to receive(:callback_slack)
        post :create, valid_params
      end
    end
  end

end