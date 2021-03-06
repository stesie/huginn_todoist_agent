module Agents
  class TodoistAgent < Agent
    include FormConfigurable

    cannot_be_scheduled!
    cannot_create_events!

    gem_dependency_check { defined?(Todoist::Client) }

    description do
      <<-MD
        The Todoist Agent creates items on your Todoist.

        To authenticate you need to either set `api_token` or provide a credential named
        `todoist_api_token` to your Todoist API token.  You can find it within the
        Todoist web frontend from "Gear Menu" > Todoist Settings > Account tab.

        Change `content` to whatever the new Todoist item should tell.  You can use liquid
        templating to include parts from the incoming event in the new item.
        Have a look at the [Wiki](https://github.com/cantino/huginn/wiki/Formatting-Events-using-Liquid)
        to learn more about liquid templating.

        In order to set a due date provide a `date_string` (which may contain all date string
        features supported by Todoist).

        `project_id` is the *ID* of the project to add the item to. Leave blank for INBOX.

        `labels` is a comma-seperated list of label IDs (or blank for no labels).

        `prority` is an integer from 1 to 4.  Where 1 means lowest (natural) priority and
        4 highest.  Defaults to natural priority (aka 1).
      MD
    end

    def default_options
      {
        "api_token" => "",
        "content" => "{{ content }}",
        "date_string" => "today",
        "project_id" => "",
        "labels" => "",
        "priority" => "",
      }
    end

    form_configurable :api_token
    form_configurable :content, type: :text
    form_configurable :date_string
    form_configurable :project_id
    form_configurable :labels
    form_configurable :priority

    def working?
      !recent_error_logs?
    end

    def validate_options
      errors.add(:base, "you need to specify your Todoist API token or provide a credential named todoist_api_token") unless options["api_token"].present? || credential("todoist_api_token").present?
    end

    def receive(incoming_events)
      incoming_events.each do |event|
        interpolate_with(event) do
          item = { "content" => interpolated["content"] }
          item["date_string"] = interpolated["date_string"] if interpolated["date_string"].present?
          item["project_id"] = interpolated["project_id"].to_i if interpolated["project_id"].present?
          item["priority"] = interpolated["priority"].to_i if interpolated["priority"].present?

          if interpolated["labels"].present?
            item["labels"] = interpolated["labels"].split(%r{,\s*}).map(&:to_i)
          end

          log "creating item: #{item}"
          todoist = Todoist::Client.new(interpolated["api_token"].present? ? interpolated["api_token"] : credential("todoist_api_token"))
          todoist.items.create(item)
          todoist.process!
        end
      end
    end

  end
end

