module Agents
  class TodoistQueryAgent < Agent
    include FormConfigurable

    cannot_receive_events!

    gem_dependency_check { defined?(Todoist::Client) && defined?(TodoistQuerynaut::Client) }

    description do
      <<-MD
        The Todoist Query Agent allows to search items on your Todoist.

        To authenticate you need to either set `api_token` or provide a credential named
        `todoist_api_token` to your Todoist API token.  You can find it within the
        Todoist web frontend from "Gear Menu" > Todoist Settings > Account tab.

        Change `query` to the [Todoist filter expression](https://support.todoist.com/hc/en-us/articles/205248842-Filters)
        you'd like to be carried out. 

        The `mode` option allows to control what information is emitted.  With the default value
        of `items` an event is emitted for every item that matches the search result.  And consequently
        no event is emitted if no items match the query.
        With `count` the agent always emits a single event, that just tells the number of matched items.
      MD
    end

    default_schedule "every_1h"

    def default_options
      {
        "api_token" => "",
        "query" => "today | overdue",
        "mode" => "items",
      }
    end

    form_configurable :api_token
    form_configurable :query, type: :text
    form_configurable :mode, type: :array, values: %w(items count)

    def working?
      !recent_error_logs?
    end

    def validate_options
      errors.add(:base, "you need to specify your Todoist API token or provide a credential named todoist_api_token") unless options["api_token"].present? || credential("todoist_api_token").present?

      if options["query"].present?
        begin
          TodoistQuerynaut::Parser.parse(options["query"])
        rescue Exception
          errors.add(:base, "query cannot be parsed correctly, check against Todoist filter expression manual")
        end
      else
        errors.add(:base, "query must not be empty")
      end
    end

    def check
      todoist = Todoist::Client.new(interpolated["api_token"].present? ? interpolated["api_token"] : credential("todoist_api_token"))
      result = TodoistQuerynaut::Client.new(todoist).run(options["query"])

      case options["mode"]
      when "items"
        result.each do |item|
          create_event payload: item
        end

      when "count"
        create_event payload: { "matched_items" => result.size }

      end
    end
  end
end
