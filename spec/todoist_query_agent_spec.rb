require "rails_helper"
require "huginn_agent/spec_helper"
require "uri"

describe Agents::TodoistQueryAgent do
  before(:each) do
    @valid_options = {
      "api_token" => "some_token_here",
      "query" => "today",
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
  end


end
