# TAHI
lalala
[![Circle CI](https://circleci.com/gh/Tahi-project/tahi/tree/master.svg?style=svg&circle-token=8f8d8e64dc324b8dd1af4e141632a46cffe78702)](https://circleci.com/gh/Tahi-project/tahi/tree/master)



# Initial Setup

## Overview

1. Run the partial setup script (`bin/setup`)
1. Make sure the following servers are already running:
    - PostgreSQL
    - Redis (run manually with `redis-server`)
1. Clone the event server repo (`tahi-slanger`) in a sibling directory
1. Make sure the following ports are clear:
    - 4567 (Slanger API)
    - 40604 (Slanger websocket)
    - 5000 (Rails server)
1. Run with `foreman start`

## Partial Automated Setup

- Clone the repo, then run

```console
./bin/setup
```

## Environment Variables

Tahi uses the [Dotenv](https://github.com/bkeepers/dotenv/) gem to manage its environment
variables in non-deployment environments (where Heroku manages the ENV). All necessary files
should be generated by the `bin/setup` script.

There are 4 important environment files: `.env`, `.env.development`, `.env.test`, `.env.local`.
`Dotenv` will load them in _that order_. Settings from `.env` will be overridden in the
`.env.(development/test)`, which will be overridden by the `.env.local`. Only the `.env` and
`.env.test` files are checked in. The `.env` file specifies some reasonable defaults for most
developer setups.

It is recommended to make machine specific modifications to the `.env.development`. Making
changes to the `.env.local` will override any settings from the `.env.test` (this can lead
to surprising differences between your machine and the CI server). This differs from the
"Dotenv best practices" which encourage making local changes to `.env.local`; we do not recommend
that approach.

foreman can also load environment variables. It is recommended that you do not
use it for this purpose, as interaction with dotenv can lead to bizarre `.env`
file load orders. Your `.foreman` file should contain the line:

```
env: ''
```

to prevent `.env` file loading.

## Event server

- Clone the [tahi-slanger](https://github.com/Tahi-project/tahi-slanger) github
  repository and follow the installation instructions

- Make sure `PUSHER_URL` is set in your environment.

When you run `foreman start`, slanger will start up as the event stream server.

By default, slanger will listen on port `4567` for API requests (requests
coming from tahi rails server) and port `40604` for websocket requests (from
tahi browser client).

# Running the server

We're using Foreman to run everything in dev.  Run `foreman start` to start the
server with the correct Procfile.

## Inserting test data

Run `rake db:setup`. This will delete any data you already have in your
database, and insert test users based on what you see in `db/seeds.rb`.

## Sending Emails

In development we sent emails through a simple SMTP server which catches any
message sent to it to display in a web interface

If you are running mailcatcher already you are ready to go, if not, please
follow these instructions:
 - install the gem `gem install mailcatcher`.
 - run in the console `mailcatcher` to start the daemon.
 - Go to http://localhost:1080/

For more information check http://mailcatcher.me/

## Upgrading node packages

To upgrade a node package, e.g., to version 1.0.1, use:
```
cd client
npm install my-package@1.0.1 --save
npm shrinkwrap
```

This should update both the `client/package.json` and
`client/npm-shrinkwrap.json` files. Commit changes to both these files.

# Tests

## Running specs

- RSpec for unit and integration specs
- Capybara and Selenium

### Running application specs

In the project directory, running `rspec` will run all unit and integration
specs for the application. Firefox will pop up to run integration tests.

### Running engine specs

There are a number of Rails engines in the `engines/` directory. To run those point the `rspec` command to their `spec/` directory, e.g.:

```
rspec engines/plos_bio_tech_check/spec/
```

It's important that the `rspec` command is run from the application directory and not the engine directory when running as they share dependencies that are loaded with the `RAILS_ROOT/spec/rails_helper.rb`

### Running vendored/gems specs

The Tahi application vendors gem(s) that are private and do not fall into the category of Rails engines. These are placed in the `vendor/gems/` directory.

Their tests can be run by `cd`'ing into the gem directory and running rspec directly, e.g.:

```
cd vendor/gems/tahi_epub
rspec spec
```

Note: you may need to run `bundle install` in order to install the necessary test dependencies for vendored gems.

## Running qunit tests from the command line

You can run the javascript specs via the command line with `rake ember:test`.

## Running qunit tests from the browser

You can also run the javascript specs from the browser. To do this run
`ember test --serve` from `client/` to see the results in the
browser.
You can run a particular test with '--module'. For example, running:
`ember test --serve --module="Integration:Discussions"
will run the Ember test that starts with `module('Integration:Discussions', {`

For help writing ember tests please see the [ember-cli testing section](http://www.ember-cli.com/#testing)

## Other Dependencies

Ghostscript is required to pass some of the tests.  Ghostscript can be installed
by running:

`brew install ghostscript`

# Documentation

Technical documentation lives in the `doc/`.  The git workflow and deploy
process are documented in [doc/git-process.txt](doc/git-process.txt). There is
a [Contribution Guide](CONTRIBUTING.md) that includes a Pull Request Checklist
template.

# Dev Notes

## Page Objects

When creating fragments, you can pass the context, if you wish to have access to
the page the fragment belongs to. You've to pass the context as an option to the
fragment on initializing:

```ruby
EditModalFragment.new(find('tr'), context: page)
```

## Why does package.json change all the time?

All of the cards in Tahi are external engines. While Rails Engines work great as backend extensions, there is no easy way to package add-ons within the same repository as engines and have them auto-detected by the application. Obviously, this is because these are two separate platforms. To make it easier for plugin developers to swap in different engines only from a Gemfile, we created an initializer that detects if these are Tahi plugins (all gems prefixed `tahi-`). The detected plugin's path is injected into the `ember-addon.paths` object in `package.json` on every server run. That’s why you see package.json change all the time.

There is no problem in committing and pushing `package.json`, the ember-addons object is flushed at every server run to get the fresh and correct paths from Tahi plugins.

## Configuring S3 direct uploads

To set up a new test bucket for your own use, run:

```bash
rake s3:create_bucket
```

You will be prompted for an AWS key/secret key pair. You can ask a team member
for these: they should only be used to bootstrap your new settings.

Your new settings will be printed to stdout, and you can copy these settings
into your `.env.development` file.

## Load testing

To wipe and restore performance data in a pristine state on tahi-performance,
run the following:

```
heroku pgbackups:restore HEROKU_POSTGRESQL_CYAN_URL b001 --app tahi-performance
```

A fully-loaded database with thousands of records can be found on S3 here:

```
tahi-performance/tahi_performance_backup.sql.zip
```

This can be downloaded and loaded locally, if needed.

The following rake task will create a new set of performance test data from scratch using FactoryGirl factories:

```
RAILS_ENV=performance bundle exec rake data:load:all
```

This will take several days to reconstruct, so you will probably want to use one of the above steps instead.

## Subset Load testing

Subset data contains about 100 users and some associated records.

To wipe and restore performance data in a pristine state on tahi-performance,
run the following:

```
heroku pgbackups:restore HEROKU_POSTGRESQL_CYAN_URL b002 --app tahi-performance
```

## Postgres Backups

Backups should be run automatically every day. If you would like to run one
manually run `heroku pg:backups capture`

You can get the URL to download a backup by running `heroku pg:backups public-url`

To list current backups `heroku pg:backups`

Your output should look something like this:

```
ID    Backup Time                Status                                Size     Database
----  -------------------------  ------------------------------------  -------  -----------------------------------------
b014  2014/08/27 14:56.44 +0000  Finished @ 2014/08/27 14:56.49 +0000  441.7KB  HEROKU_POSTGRESQL_ROSE_URL (DATABASE_URL)
b015  2014/09/02 13:35.44 +0000  Finished @ 2014/09/02 13:35.48 +0000  465.2KB  HEROKU_POSTGRESQL_ROSE_URL (DATABASE_URL)
b016  2014/09/11 14:42.05 +0000  Finished @ 2014/09/11 14:42.08 +0000  495.7KB  HEROKU_POSTGRESQL_ROSE_URL (DATABASE_URL)
b017  2014/09/16 15:07.00 +0000  Finished @ 2014/09/16 15:07.03 +0000  515.0KB  HEROKU_POSTGRESQL_ROSE_URL (DATABASE_URL)
b018  2014/10/01 12:41.31 +0000  Finished @ 2014/10/01 12:41.35 +0000  528.0KB  HEROKU_POSTGRESQL_ROSE_URL (DATABASE_URL)
b019  2014/10/09 17:48.40 +0000  Finished @ 2014/10/09 17:48.49 +0000  568.5KB  HEROKU_POSTGRESQL_ROSE_URL (DATABASE_URL)
b020  2014/10/13 13:10.26 +0000  Finished @ 2014/10/13 13:10.30 +0000  576.2KB  HEROKU_POSTGRESQL_ROSE_URL (DATABASE_URL)
b021  2014/10/16 14:04.13 +0000  Finished @ 2014/10/16 14:04.18 +0000  593.2KB  HEROKU_POSTGRESQL_ROSE_URL (DATABASE_URL)
```

To restore to a specific backup, use the ID and Database in your list output.
E.G.

```
heroku pgbackups:restore HEROKUPOSTGRESQL_ROSE_URL b020
```

# Deploying Aperta

Please see the
[Release Information page on confluence](https://developer.plos.org/confluence/display/TAHI/Release+Information)
for information on how to deploy aperta

# Documentation

To generate documentation, run the following command from the application root:

```
rake doc:app
```

Open the generated documentation from `doc/api/index.html` or
`doc/client/index.html` (javascript) in your browser.

Please document Ruby code with
[rdoc](http://docs.seattlerb.org/rdoc/RDoc/Markup.html) and Javascript with
[yuidoc](http://yui.github.io/yuidoc/)
