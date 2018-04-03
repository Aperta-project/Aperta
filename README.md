# Aperta

[![CircleCI](https://circleci.com/gh/Aperta-project/Aperta.svg?style=svg&circle-token=053baf28a00d1f8a35d40014fe8e3d840eadbd10)](https://circleci.com/gh/Aperta-project/Aperta)

Aperta is a platform for building review workflow systems for scientific
research outputs.

# Initial Setup

## Overview

Aperta is supported on Linux and Mac. Our `bin/setup` script should
work on Macs, Debian and Ubuntu.

1. Ensure you have Ruby 2.3.6 installed. We recommend using
   [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/)
   to manage your ruby versions. Aperta will probably work on other
   Ruby versions, but we only provide support for 2.3.6.
2. Have a keypair for AWS account with permissions to create new IAM
   users and S3 buckets available.
3. Run the setup script (`bin/setup`)
4. Run `foreman start`
5. Visit http://localhost:5000/ in your browser.

## Detailed steps

### Install ruby

We recommend using a ruby version manager, e.g. [rvm](https://rvm.io)
or [rbenv](https://github.com/rbenv/rbenv). Either one should meet
your needs. Installing them is outside the scope of this README.
Please refer to the installation instructions in those project.

### Set up AWS

The `bin/setup` script will prompt you for an AWS key/secret key pair.
This should be a key pair attached to a user that can create a new S3
bucket and IAM user and set up access. The simplest thing would be to
attach it to a root user. The steps are beyond this README, but you
can get started [here](https://github.com/aperta-project/aperta/wiki/AWS-Setup)

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
- Create a new AWS IAM user and S3 bucket and configure them.

### Run the server

Run `foreman start` to start the web server, worker, and slanger.

### More information

For more information for developers, please visit the [wiki](https://github.com/Aperta-project/Aperta/wiki)

### Troubleshooting

1. Make sure the following servers are already running and listening
   on the correct ports:
    - PostgreSQL (5432)
    - Redis (6379)
2. Make sure the following ports are open:
    - 4567 (Slanger API)
    - 40604 (Slanger websocket)
    - 5000 (Rails server)

Note that the `bin/setup` can be run as many times as you like as you
correct issues that it runs into.

### Running the test suite

Aperta uses rspec for ruby testing and qunit for javascript testing. To run
the rspec tests, use `bundle exec rspec`. To run the qunit test, use `bundle exec rake ember:test`.
