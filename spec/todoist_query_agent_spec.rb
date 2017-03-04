require "rails_helper"
require "huginn_agent/spec_helper"
require "uri"

require_relative "./spec_helper"

describe Agents::TodoistQueryAgent do
  before(:each) do
    @valid_options = {
      "api_token" => "some_token_here",
      "query" => "overdue",
      "mode" => "items",
    }
    @checker = Agents::TodoistQueryAgent.new(:name => "TodoistQueryAgent", :options => @valid_options)
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

    it "should reject an empty query" do
      @checker.options["query"] = nil
      expect(@checker).not_to be_valid
    end

    it "should reject invalid query syntax" do
      @checker.options["query"] = "some_invalid_query"
      expect(@checker).not_to be_valid
    end
  end

  describe "#check" do
    before :each do
      stub_request(:post, "https://todoist.com/API/v6/query").
        with(:body => {"queries" => "[\"overdue\"]", "token" => "some_token_here"}).
        to_return(:status => 200, :body => json_response_raw("query_overdue"), :headers => {})
    end

    it "should execute the query and emit events for every item" do
      expect { @checker.check }.to change {Event.count}.by(2)
    end

    it "should emit the number of matched items with mode=count" do
      @checker.options["mode"] = "count"
      expect { @checker.check }.to change {Event.count}.by(1)

      event = Event.last
      expect(event.payload).to eq({ "matched_items" => 2 })
    end
  end
end
