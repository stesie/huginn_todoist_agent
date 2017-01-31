require 'rails_helper'
require 'huginn_agent/spec_helper'

describe Agents::TodoistAgent do
  before(:each) do
    @valid_options = Agents::TodoistAgent.new.default_options
    @checker = Agents::TodoistAgent.new(:name => "TodoistAgent", :options => @valid_options)
    @checker.user = users(:bob)
    @checker.save!
  end

  pending "add specs here"
end
