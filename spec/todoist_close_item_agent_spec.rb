require "rails_helper"
require "huginn_agent/spec_helper"
require "uri"

require_relative "./spec_helper"

describe Agents::TodoistCloseItemAgent do
  before(:each) do
    @valid_options = {
        "api_token" => "some_token_here",
        "id" => "1234",
    }
    @checker = Agents::TodoistCloseItemAgent.new(:name => "TodoistCloseItemAgent", :options => @valid_options)
    @checker.user = users(:bob)
    @checker.save!
  end

  describe "#validate_options" do
    before do
      expect(@checker).to be_valid
    end

    it "should reject an empty api_token" do
      @checker.options["api_token"] = nil
      expect(@checker).not_to be_valid
    end

    it "should allow a credential (instead of api_token)" do
      @checker.user.user_credentials.create :credential_name => "todoist_api_token", :credential_value => "some_credential_here"
      @checker.options["api_token"] = nil
      expect(@checker).to be_valid
    end

    it "should reject an empty id field" do
      @checker.options["id"] = nil
      expect(@checker).not_to be_valid
    end
  end

  def assert_item_close(item_id)
    expect(WebMock).to have_requested(:post, "https://todoist.com/API/v7/sync").
    with { |request|
      expect(request.headers["Content-Type"]).to eq("application/x-www-form-urlencoded")

      form_data = URI.decode_www_form(request.body)
      expect(form_data.assoc("token").last).to eq("some_token_here")

      json_data = ActiveSupport::JSON.decode(form_data.assoc("commands").last)
      expect(json_data.length).to eq(1)

      expect(json_data[0]["type"]).to eq("item_close")
      expect(json_data[0]["args"]["id"]).to eq(item_id)
    }
  end

  describe "#check" do
    it "should close the referenced item" do
      stub_request(:post, "https://todoist.com/API/v7/sync").to_return(:status => 200, :body => '{}')

      @checker.check
      assert_item_close "1234"
    end

  end

  describe "#receive" do
    it "should close the referenced item via interpolation" do
      stub_request(:post, "https://todoist.com/API/v7/sync").to_return(:status => 200, :body => '{}')

      event = Event.new
      event.agent = agents(:bob_weather_agent)
      event.payload = {
        "id" => "2345",
      }

      @checker.options["id"] = "{{ id }}"

      @checker.receive([event])
      assert_item_close "2345"
    end
  end
end
