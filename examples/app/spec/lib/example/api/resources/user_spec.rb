require 'spec_helper'
require 'example/api'
require 'json'

describe Example::Api::Resources::User do

  include Rack::Test::Methods

  def app
    Example::API
  end

  let(:user_json) { {firstName: "Mary", lastName: "Smith"}.to_json }
  let(:user) { double("user", update_attributes: true, to_json: user_json) }

  before do
    Example::Models::User.stub(:find_by_id).with("1").and_return(user)
  end

  describe "with an unsupported method" do

    subject { post("/users/1", {}, {}) }

    let(:rack_env) { {'CONTENT_TYPE' => "application/json-patch+json"} }

    it "includes the Accept-Patch header" do
      subject
      last_response.headers['Accept-Patch'].should eq "application/json-patch+json"
    end

    it "includes the Allow header" do
      subject
      last_response.headers["Allow"].should eq "GET, PATCH"
    end

  end

  describe "PATCH" do

    let(:request_body) { [{op: "add", path: "firstName", value: "Fred"}].to_json }
    let(:user_json) { {firstName: "Mary", lastName: "Smith"}.to_json }
    let(:rack_env) { {'CONTENT_TYPE' => "application/json-patch+json"} }
    subject { patch("/users/1", request_body, rack_env) }

    context "with the wrong content type" do
      let(:rack_env) { {'CONTENT_TYPE' => "application/json"} }

      it "responds with a 415" do
        subject
        last_response.status.should eq 415
      end
    end

    context "when the user exists" do

      it "updates the user" do
        user.should_receive(:update_attributes).with(JSON.parse(request_body))
        subject
      end

      it "responds with a 200" do
        subject
        last_response.status.should eq 200
      end

      it "includes a representation of the user" do
        subject
        last_response.body.should eq user_json
      end

      it "includes a Content-Location header" do
        subject
        last_response.headers['Content-Location'].should eq "http://example.org/users/1"
      end

    end

    context "when the user does not exist" do

      let(:user) { nil }

      it "responds with a 404" do
        subject
        last_response.status.should eq 404
      end

    end

  end

  describe "GET" do

    let(:rack_env) { {"Accept" => "application/json"} }
    subject { get("/users/1", {}, rack_env) }


    context "when the user exists" do
      it "returns a 200 response" do
        subject
        last_response.status.should eq 200
      end

      it "returns a json body" do
        subject
        last_response.body.should eq user_json
      end

      it "returns a Content-Type of application/json" do
        subject
        last_response.headers['Content-Type'].should eq "application/json"
      end
    end

    context "when the user does not exist" do

      let(:user) { nil }

      it "returns a 404 response" do
        subject
        last_response.status.should eq 404
      end

    end

  end

end