module Agents
  class TodoistQueryAgent < Agent
    include FormConfigurable

    cannot_receive_events!

    gem_dependency_check { defined?(Todoist::Client) }

    description do
      <<-MD
        The Todoist Query Agent allows to search items on your Todoist.

        To authenticate you need to either set `api_token` or provide a credential named
        `todoist_api_token` to your Todoist API token.  You can find it within the
        Todoist web frontend from "Gear Menu" > Todoist Settings > Account tab.

        Change `query` to the [Todoist filter expression](https://support.todoist.com/hc/en-us/articles/205248842-Filters)
        you'd like to be carried out. 
      MD
    end

    default_schedule "every_1h"

    def default_options
      {
        "api_token" => "",
        "query" => "today | overdue",
      }
    end

    form_configurable :api_token
    form_configurable :query, type: :text

    def working?
      !recent_error_logs?
    end

    def validate_options
      errors.add(:base, "you need to specify your Todoist API token or provide a credential named todoist_api_token") unless options["api_token"].present? || credential("todoist_api_token").present?
      errors.add(:base, "query must not be empty") unless options["query"].present?
    end
  end
end
