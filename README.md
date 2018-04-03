# Timestamp API

[![Build Status](https://travis-ci.org/alpinelab/timestamp_api.svg?branch=master)](https://travis-ci.org/alpinelab/timestamp_api)
[![Code Climate](https://codeclimate.com/github/alpinelab/timestamp_api/badges/gpa.svg)](https://codeclimate.com/github/alpinelab/timestamp_api)
[![Test Coverage](https://codeclimate.com/github/alpinelab/timestamp_api/badges/coverage.svg)](https://codeclimate.com/github/alpinelab/timestamp_api/coverage)
[![Gem Version](https://badge.fury.io/rb/timestamp_api.svg)](https://badge.fury.io/rb/timestamp_api)
[![security](https://hakiri.io/github/alpinelab/timestamp_api/master.svg)](https://hakiri.io/github/alpinelab/timestamp_api/master)
[![Dependency Status](https://gemnasium.com/alpinelab/timestamp_api.svg)](https://gemnasium.com/alpinelab/timestamp_api)

This gem is an unofficial set of Ruby bindings for the [Timestamp](https://www.timestamphq.com) API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "timestamp_api"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install timestamp_api

## Usage

Configure your Timestamp API key by setting environment variable `TIMESTAMP_API_KEY`:
```shell
$ TIMESTAMP_API_KEY="YOUR_API_KEY" bin/console
```

Or set it in ruby:
```ruby
TimestampAPI.api_key = "YOUR_API_KEY"
```

#### Clients

List clients:
```ruby
TimestampAPI::Client.all # => Returns all clients
```

Find a given client:
```ruby
client = TimestampAPI::Client.find(123)

client.name # => "My beloved customer"
```

#### Projects

List projects:
```ruby
TimestampAPI::Project.all # => Returns all projects
```

Find a given project:
```ruby
project = TimestampAPI::Project.find(123)

project.name                            # => "My awesome project"
project.client.name                     # => "My beloved customer"
project.enter_time(123, Date.today, 60) # => Creates a 60 minutes time entry for today on task 123 and returns the created TimeEntry
```

#### Users

List users:
```ruby
TimestampAPI::User.all # => Returns all users
```

Find a given user:
```ruby
user = TimestampAPI::User.find(123)

user.full_name # => "Great developer"
```

#### Tasks

List tasks:
```ruby
TimestampAPI::Task.all                 # => Returns all tasks
TimestampAPI::Task.for_project_id(123) # => Returns tasks for project 123
```

Find a given task:
```ruby
task = TimestampAPI::Task.find(123)

task.name         # => "My fantastic task"
task.project.name # => "My awesome project"
```

#### TimeEntry

List time entries:
```ruby
TimestampAPI::TimeEntry.all              # => Returns all time entries
TimestampAPI::TimeEntry.for_task_id(123) # => Returns time entries for task 123
```

Find a given time entry:
```ruby
time_entry = TimestampAPI::TimeEntry.find(123)

time_entry.comment        # => "Stuff got done"
time_entry.client.name    # => "My beloved customer"
time_entry.project.name   # => "My awesome project"
time_entry.task.name      # => "My fantastic task"
time_entry.user.full_name # => "Great developer"
```

#### Event

List events:
```ruby
TimestampAPI::Event.all # => Returns all events
```

Find a given event:
```ruby
event = TimestampAPI::Event.find(123)

event.object # => Returns the object on which event occured
```

## Objects representation

#### Models

The objects are represented by model classes (that inherits from `TimestampAPI::Model`):
```ruby
project = TimestampAPI::Project.find(123456)

project.class                     # => TimestampAPI::Project
project.is_a? TimestampAPI::Model # => true
```

#### Collections

Collections of objects are represented by `TimestampAPI::Collection` that inherits from `Array` (and implement the chainable `.where(conditions)` filter method described above). It means any `Array` method works on `TimestampAPI::Collection`:
```ruby
projects = TimestampAPI::Project.all

projects.class       # => TimestampAPI::Collection
projects.map(&:name) # => ["A project", "Another project", "One more project"]
```

#### Relationships

Models can can bound together and are accessible using a simple getter:

Exemple: find the client bound to a project:
```ruby
project = TimestampAPI::Project.find(123)

project.client.name # => "My beloved customer"
```

:information_source: First call to such a relation getter will trigger an API request and memoize the response for network optimization.

## Filtering

You can filter any object collection using the handy `.where()` syntax:
```ruby
projects = TimestampAPI::Project.all

projects.where(is_public: true)                          # => returns all public projects
projects.where(is_public: true, is_billable: true)       # => returns all projects that are both public and billable
projects.where(is_public: true).where(is_billable: true) # => same as above: `where` is chainable \o/
```

:information_source: This does not filter objects **before** the network call (like ActiveRecord does), it's only a more elegant way of calling `Array#select` on the `Collection`

### Low level API calls

The above methods are simple wrappers around the generic low-level-ish API request method `TimestampAPI.request` that take a HTTP `method` (verb) and a `path` (to be appended to preconfigured API endpoint URL):
```ruby
TimestampAPI.request(:get, "/projects")        # Same as TimestampAPI::Project.all
TimestampAPI.request(:get, "/projects/123456") # Same as TimestampAPI::Project.find(123456)
```

To output all network requests done, you can set verbosity on:
```ruby
TimestampAPI.verbose = true
```

## Reverse engineering

As the API is not documented nor even officially supported by Timestamp, we're trying to reverse-engineer it.

:warning: This means that Timestamp can introduce breaking changes within their API without prior notice at any time (and thus break this gem).

It also means that if you're willing to hack into it with us, you're very welcome :+1:

While logged in, the Timestamp API data can be explored from your favourite browser (with a JSON viewer addon, if needed) here: https://api.ontimestamp.com/api

There's also a `bin/console` executable provided with this gem, if you want a REPL to hack around.

### What's implemented already ?

* [x] `Project` model
* [x] `Client` model
* [x] `Task` model
* [x] `User` model (their `roles` could be enhanced, though)
* [x] `TimeEntry` model
* [x] `Event` model
* [x] `belongs_to` relationships

### What's not implemented yet ?

* [ ] _all other models_ :scream:
* [ ] _almost all write operations_
* [ ] `has_many` relationships
* [ ] document and integrate [Inch-CI](https://inch-ci.org)
* [ ] timers

Any help is lovely appreciated to complete the full feature set :heart:

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/alpinelab/timestamp_api/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

This code is distributed by [Alpine Lab](http://www.alpine-lab.com) under the terms of the MIT license.

See [LICENCE.md](https://github.com/alpinelab/timestamp_api/blob/develop/LICENSE.md)
