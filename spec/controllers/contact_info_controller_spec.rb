require 'rails_helper'

describe ContactInfoController do
  context "POST" do
    context "200" do
      let(:params) { {"text" => "Sean"} }
      it "returns 200 with valid params" do
        post :create, params
        expect(response.status).to eq(200)
      end

      it "renders create template" do
        post :create, params
        expect(response).to render_template("create")
      end

      it "calls back slack after rendering" do
        expect_any_instance_of(ContactInfo).to receive(:callback_slack)
        post :create, params
      end
    end

    context "422" do
      let(:params) { {"text" => "a_bad_name"} }
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
