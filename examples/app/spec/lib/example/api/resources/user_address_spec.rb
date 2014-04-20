require 'spec_helper'
require 'example/api'
require 'json'

describe Example::Api::Resources::UserAddress do

  include Rack::Test::Methods

  def app
    Example::API
  end

  let(:address_json) { {street: "123 Smith St", city: "Smithston"}.to_json }
  let(:address) { double("address", update_attributes: true, to_json: address_json) }
  let(:user) { double("user", update_attributes: true, address: address, :address= => nil) }

  before do
    Example::Models::User.stub(:find_by_id).with("1").and_return(user)
    Example::Models::Address.stub(:find_by_user_id).with("1").and_return(address)
  end

  describe "PATCH" do

    let(:request_body) { [{op: "add", path: "street", value: "567 Main St"}].to_json }
    let(:rack_env) { {'CONTENT_TYPE' => "application/json-patch+json"} }
    subject { patch("/users/1/address", request_body, rack_env) }

    context "with the wrong content type" do
      let(:rack_env) { {'CONTENT_TYPE' => "application/json"} }

      it "responds with a 415" do
        subject
        last_response.status.should eq 415
      end
    end

    context "when the user does not exist" do

      let(:user) { nil }

      it "returns a 404" do
        subject
        last_response.status.should eq 404
      end
    end

    context "when the user exists, but the address does not" do

      before do
        user.stub(:address).and_return(nil)
        Example::Models::Address.stub(:new).and_return(address)
        address.stub(:save)
        user.stub(:save)
      end

      it "creates a new address" do
        Example::Models::Address.should_receive(:new)
        address.should_receive(:save)
        user.should_receive(:save)
        subject
      end

      it "returns a 201 response" do
        subject
        last_response.status.should eq 201
      end

      it "includes a representation of the address" do
        subject
        last_response.body.should eq address_json
      end

      it "includes a Content-Location header" do
        subject
        last_response.headers['Content-Location'].should eq "http://example.org/users/1/address"
      end

    end

    context "when the user and the address exist" do

      it "updates the address" do
        address.should_receive(:update_attributes).with(JSON.parse(request_body))
        subject
      end

      it "responds with a 200" do
        subject
        last_response.status.should eq 200
      end

      it "includes a representation of the address" do
        subject
        last_response.body.should eq address_json
      end

    end

  end

  describe "GET" do

    let(:rack_env) { {"Accept" => "application/json"} }
    subject { get("/users/1/address", {}, rack_env) }


    context "when the address exists" do
      it "returns a 200 response" do
        subject
        last_response.status.should eq 200
      end

      it "returns a json body" do
        subject
        last_response.body.should eq address_json
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

    context "when the address does not exist" do

      let(:address) { nil }

      it "returns a 404 response" do
        subject
        last_response.status.should eq 404
      end

    end

  end

end