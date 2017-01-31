module Agents
  class TodoistAgent < Agent
    default_schedule '12h'

    description <<-MD
      Add a Agent description here
    MD

    def default_options
      {
      }
    end

    def validate_options
    end

#    def check
#    end

#    def receive(incoming_events)
#    end
  end
end
