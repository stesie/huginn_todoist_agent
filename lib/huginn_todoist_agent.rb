require 'huginn_agent'

# Load todoist (from ruby-todoist-api Gem), ignoring LoadErrors.  This way Huginn
# still starts up successfully, yet shows "Missing Gems" error in the frontend.
begin
  require 'todoist'
rescue LoadError
end

#HuginnAgent.load 'huginn_todoist_agent/concerns/my_agent_concern'
HuginnAgent.register 'huginn_todoist_agent/todoist_agent'
