# TodoistAgent

The Todoist Agent is a plugin for [Huginn](https://github.com/cantino/huginn) that
creates one item on your [Todoist](https://todoist.com) for every event it receives.

It allows to set the items due date, project, priority and labels (if you have
Todoist Pro version).

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

TODO: Write usage instructions here

## Development

Running `rake` will clone and set up Huginn in `spec/huginn` to run the specs of the Gem in Huginn as if they would be build-in Agents. The desired Huginn repository and branch can be modified in the `Rakefile`:

```ruby
HuginnAgent.load_tasks(branch: '<your branch>', remote: 'https://github.com/<github user>/huginn.git')
```

Make sure to delete the `spec/huginn` directory and re-run `rake` after changing the `remote` to update the Huginn source code.

After the setup is done `rake spec` will only run the tests, without cloning the Huginn source again.

## Contributing

1. Fork it ( https://github.com/stesie/huginn_todoist_agent/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
