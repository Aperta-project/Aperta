# Aperta

[![CircleCI](https://circleci.com/gh/Aperta-project/Aperta.svg?style=svg&circle-token=053baf28a00d1f8a35d40014fe8e3d840eadbd10)](https://circleci.com/gh/Aperta-project/Aperta)

Aperta is a platform for building review workflow systems for scientific
research outputs.

# Initial Setup

## Overview

1. Ensure you have Ruby 2.3.6 installed. We recommend using
   [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/) to manage
   your ruby versions. Aperta will probably work on other Ruby versions, but
   only support 2.3.6.
2. Run the setup script (`bin/setup`)
3. Run `foreman start`
4. Visit http://localhost:5000/ in your browser.

## Detailed steps

### Install ruby

We recommend using a ruby version manager, either rvm or rbenv. Both should meet
your needs. Installing them is outside the scope of this README. Please refer to
the installation instructions in those project.

### Automated Setup

- Run:

```console
./bin/setup
```

Running this script will:
- Install dependencies
- Create the following config files:
    - .env.development
    - .foreman
    - Procfile.local
    - config/database.yml
- Create a new database
- Create a new AWS IAM user and S3 bucket and configure them. You will
  be prompted for an AWS key/secret key pair. This should be a key
  pair attached to a user that can create a new S3 bucket and IAM user
  and set up access. The simplest thing would be to attach it to a
  root user.

### Run the server

Run `foreman start` to start the web server, worker, and slanger.

### More information

For more information for developers, please visit the [wiki](https://github.com/Aperta-project/Aperta/wiki)

### Troubleshooting

1. Make sure the following servers are already running:
    - PostgreSQL
    - Redis
2. Make sure the following ports are clear:
    - 4567 (Slanger API)
    - 40604 (Slanger websocket)
    - 5000 (Rails server)

### Running the test suite

Aperta uses rspec for ruby testing and qunit for javascript testing. To run
the rspec tests, use `bundle exec rspec`. To run the qunit test, use `bundle exec rake ember:test`.
