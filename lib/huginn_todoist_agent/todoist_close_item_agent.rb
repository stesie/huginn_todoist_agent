module Agents
  class TodoistCloseItemAgent < Agent
    include FormConfigurable

    cannot_create_events!

    gem_dependency_check { defined?(Todoist::Client) }

    description do
      <<-MD
        The Todoist Close Item Agent closes items on your Todoist.

        To authenticate you need to either set `api_token` or provide a credential named
        `todoist_api_token` to your Todoist API token.  You can find it within the
        Todoist web frontend from "Gear Menu" > Todoist Settings > Account tab.

	Change `id` to whatever the ID of the item you would want to be closed is.  You
	can route query results from "Todoist Query Agent" to this agent, as it will
	pick the `id` property from it (and ignore the rest).
      MD
    end

    default_schedule "never"

    def default_options
      {
        "api_token" => "",
        "id" => "",
      }
    end

    form_configurable :api_token
    form_configurable :id

    def working?
      !recent_error_logs?
    end

    def validate_options
      errors.add(:base, "you need to specify your Todoist API token or provide a credential named todoist_api_token") unless options["api_token"].present? || credential("todoist_api_token").present?
    end

    def check
      log "closing item: #{interpolated["id"]}"
      todoist = Todoist::Client.new(interpolated["api_token"].present? ? interpolated["api_token"] : credential("todoist_api_token"))
      todoist.items.close(interpolated["id"])
      todoist.queue.process!
    end

    def receive(incoming_events)
      incoming_events.each do |event|
        interpolate_with(event) do

          log "closing item: #{interpolated["id"]}"
          todoist = Todoist::Client.new(interpolated["api_token"].present? ? interpolated["api_token"] : credential("todoist_api_token"))
          todoist.items.close(interpolated["id"])
	  todoist.queue.process!
        end
      end
    end

  end
end


