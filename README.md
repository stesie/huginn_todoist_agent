# TodoistAgent

## NOTE: This Agent No Longer Works
The Todoist API has changed and it no longer works. However, the Post Agent works perfectly with the Todoist [REST API](https://developer.todoist.com/rest/v1/). See below for an example of how to set this up:
```json
{
  "post_url": "https://api.todoist.com/rest/v1/tasks",
  "expected_receive_period_in_days": "1",
  "content_type": "json",
  "method": "post",
  "payload": {
    "content": "Test from api",
    "due_string": "today",
    "priority": 3
  },
  "headers": {
    "X-Request-Id": "{{ 'now' | date: '%s%N' }}",
    "Authorization": "Bearer PUT_YOUR_TOKEN_HERE"
  },
  "emit_events": "true",
  "no_merge": "true",
  "output_mode": "clean"
}
```

[![Build Status](https://travis-ci.org/stesie/huginn_todoist_agent.svg?branch=master)](https://travis-ci.org/stesie/huginn_todoist_agent)
[![Gem Version](https://badge.fury.io/rb/huginn_todoist_agent.svg)](https://badge.fury.io/rb/huginn_todoist_agent)
[![Coverage Status](https://coveralls.io/repos/github/stesie/huginn_todoist_agent/badge.svg?branch=master)](https://coveralls.io/github/stesie/huginn_todoist_agent?branch=master)

The Todoist Agent is a plugin for [Huginn](https://github.com/cantino/huginn)
that integrates it with your [Todoist](https://todoist.com).  It allows to
create new items, search for already existing items as well as close existing
items.

For new items it allows to set the items' due date, project, priority and
labels (if you have Todoist Pro version).

## Installation

Add this string to your Huginn's .env `ADDITIONAL_GEMS` configuration:

```ruby
huginn_todoist_agent
# when only using this agent gem it should look like hits:
ADDITIONAL_GEMS=huginn_todoist_agent
```

And then execute:

    $ bundle

## Usage

After installing this Agent plugin in Huginn go to Credentials and add a
new entry with name `todoist_api_token` and enter your Todoist API token
there (you can find that in Todoist's web frontend from "Gear Menu" > Todoist
Settings > Account tab).

Then create a new agent and select "Todoist Agent" as type, give it a
name and pick an event source.  Last not least provide some "content",
i.e. what you want the new Todoist item to tell.  You can either just
enter static text or re-use content from the incoming event by using
some [liquid templating](https://github.com/cantino/huginn/wiki/Formatting-Events-using-Liquid).

## Development

Running `rake` will clone and set up Huginn in `spec/huginn` to run the specs of the Gem in Huginn as if they would be build-in Agents. The desired Huginn repository and branch can be modified in the `Rakefile`:

```ruby
HuginnAgent.load_tasks(branch: '<your branch>', remote: 'https://github.com/<github user>/huginn.git')
```

Make sure to delete the `spec/huginn` directory and re-run `rake` after changing the `remote` to update the Huginn source code.

After the setup is done `rake spec` will only run the tests, without cloning the Huginn source again.

This requires a local MySQL server running.  Credentials can be configured in `spec/huginn/.env`.

## Contributing

1. Fork it ( https://github.com/stesie/huginn_todoist_agent/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
