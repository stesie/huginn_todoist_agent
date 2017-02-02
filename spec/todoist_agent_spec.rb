require 'rails_helper'
require 'huginn_agent/spec_helper'
require 'uri'

describe Agents::TodoistAgent do
  before(:each) do
    @valid_options = {
      'token' => 'some_token_here',
      'content' => 'foobar',
    }
    @checker = Agents::TodoistAgent.new(:name => "TodoistAgent", :options => @valid_options)
    @checker.user = users(:bob)
    @checker.save!

    @event = Event.new
    @event.agent = agents(:bob_weather_agent)
    @event.payload = {
      'somekey' => 'somevalue',
      'some_date' => 'May 23',
      'some_project_id' => '2342',
      'some_priority' => '2',
      'a_single_label' => '42',
      'some_labels' => '23,42,  5',
    }

    @expected_token = "some_token_here"
    @sent_requests = Array.new
    stub_request(:post, "https://todoist.com/API/v6/sync").
      to_return { |request|
	expect(request.headers["Content-Type"]).to eq("application/x-www-form-urlencoded")

	form_data = URI.decode_www_form(request.body)
	expect(form_data.assoc("token").last).to eq(@expected_token)

	json_data = ActiveSupport::JSON.decode(form_data.assoc("commands").last)
	expect(json_data.length).to eq(1)

	@sent_requests << req = json_data[0]

	case json_data[0]["type"]
	when "item_add"
	  json_response = {
	    "TempIdMapping" => {
	      json_data[0]["temp_id"] => 81662555
	    },
	    "seq_no_global" => 11248873939,
	    "seq_no" => 11248873939,
	    "UserId" => 9933517,
	    "SyncStatus" => {
	      json_data[0]["uuid"] => "oK"
	    },
	  }
	else
	  raise "Unexpected type: #{json_data[0]["type"]}"
	end

	{ status: 200, body: ActiveSupport::JSON.encode(json_response), headers: { "Content-type" => "application/json" } }
      }
  end

  describe "#validate_options" do
    before do
      expect(@checker).to be_valid
    end

    it "should reject an empty token" do
      @checker.options["token"] = nil
      expect(@checker).not_to be_valid
    end

    it "should also allow a credential" do
      @checker.user.user_credentials.create :credential_name => "todoist_auth_token", :credential_value => "some_credential_here"
      @checker.options["token"] = nil
      expect(@checker).to be_valid
    end
  end

  describe "#receive" do
    describe "with static content configuration" do
      it 'can create a new static item' do
	@checker.receive([@event])
	expect(@sent_requests.length).to eq(1)
	expect(@sent_requests[0]["type"]).to eq("item_add")
	expect(@sent_requests[0]["args"]["content"]).to eq("foobar")
      end

      it "passes date_string to the new item" do
	@checker.options["date_string"] = "today"
	expect(@checker).to be_valid

	@checker.receive([@event])
	expect(@sent_requests[0]["args"]["date_string"]).to eq("today")
      end

      it "passes project_id to the new item" do
	@checker.options["project_id"] = "23"
	expect(@checker).to be_valid

	@checker.receive([@event])
	expect(@sent_requests[0]["args"]["project_id"]).to eq(23)
      end

      it "passes priority to the new item" do
	@checker.options["priority"] = "3"
	expect(@checker).to be_valid

	@checker.receive([@event])
	expect(@sent_requests[0]["args"]["priority"]).to eq(3)
      end

      it "passes a single label to the new item" do
	@checker.options["labels"] = "23"
	expect(@checker).to be_valid

	@checker.receive([@event])
	expect(@sent_requests[0]["args"]["labels"]).to eq([23])
      end

      it "passes multiple labels to the new item" do
	@checker.options["labels"] = "23, 42"
	expect(@checker).to be_valid

	@checker.receive([@event])
	expect(@sent_requests[0]["args"]["labels"]).to eq([23, 42])
      end
    end

    describe "with content interpolation" do
      it 'content can be interpolated' do
	@checker.options["content"] = "Event Data: {{ somekey }}"
	expect(@checker).to be_valid

	@checker.receive([@event])
	expect(@sent_requests[0]["args"]["content"]).to eq("Event Data: somevalue")
      end

      it "date_string can be interpolated" do
	@checker.options["date_string"] = "{{ some_date }}"
	expect(@checker).to be_valid

	@checker.receive([@event])
	expect(@sent_requests[0]["args"]["date_string"]).to eq("May 23")
      end

      it "project_id can be interpolated" do
	@checker.options["project_id"] = "{{ some_project_id }}"
	expect(@checker).to be_valid

	@checker.receive([@event])
	expect(@sent_requests[0]["args"]["project_id"]).to eq(2342)
      end

      it "priority can be interpolated" do
	@checker.options["priority"] = "{{ some_priority }}"
	expect(@checker).to be_valid

	@checker.receive([@event])
	expect(@sent_requests[0]["args"]["priority"]).to eq(2)
      end

      it "single label can be interpolated" do
	@checker.options["labels"] = "{{ a_single_label }}"
	expect(@checker).to be_valid

	@checker.receive([@event])
	expect(@sent_requests[0]["args"]["labels"]).to eq([42])
      end

      it "multiple labels can be interpolated" do
	@checker.options["labels"] = "{{ some_labels }}"
	expect(@checker).to be_valid

	@checker.receive([@event])
	expect(@sent_requests[0]["args"]["labels"]).to eq([23, 42, 5])
      end
    end

    it 'creates two items for two events' do
      @checker.receive([@event, @event])
      expect(@sent_requests.length).to eq(2)
    end

    it "should use the credential token if no token is present" do
      @checker.user.user_credentials.create :credential_name => "todoist_auth_token", :credential_value => "some_credential_here"
      @checker.options["token"] = nil

      @expected_token = "some_credential_here"
      @checker.receive([@event])

      expect(@sent_requests.length).to eq(1)
      expect(@sent_requests[0]["type"]).to eq("item_add")
      expect(@sent_requests[0]["args"]["content"]).to eq("foobar")
    end

    it "should use the credential token if an empty token is given" do
      @checker.user.user_credentials.create :credential_name => "todoist_auth_token", :credential_value => "some_credential_here"
      @checker.options["token"] = ""

      @expected_token = "some_credential_here"
      @checker.receive([@event])

      expect(@sent_requests.length).to eq(1)
      expect(@sent_requests[0]["type"]).to eq("item_add")
      expect(@sent_requests[0]["args"]["content"]).to eq("foobar")
    end

    it "should use the provided token, if both a credential and immediate token are given" do
      @checker.user.user_credentials.create :credential_name => "todoist_auth_token", :credential_value => "some_credential_here"
      @checker.receive([@event])

      expect(@sent_requests.length).to eq(1)
      expect(@sent_requests[0]["type"]).to eq("item_add")
      expect(@sent_requests[0]["args"]["content"]).to eq("foobar")
    end
  end
end
