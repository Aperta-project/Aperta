# TAHI

## Development Notes

### Initial Setup

- Clone the repo
- `brew install imagemagick --with-libtiff`
- Most of the javascript for the app is being handled by Bower.  You'll need to have node installed
in order to proceed.  `brew install node` and then `npm install bower -g`
- All bower dependencies are found in the `Bowerfile`
- If you're installing new bower components you'll want to read the [rails-bower docs](https://github.com/42dev/bower-rails#rake-tasks), especially if 
your components have stylesheets (`rake bower:resolve`)
- You'll need redis.  `brew install redis` is the easiest way to get it.
- Create database user for tahi `createuser -s -r tahi`
- `cp .env-sample .env.development` and then uncomment the environment variables in `.env.development`

### Setting up the event server

You will need:

- Go (`brew install go` is easiest) with your [$GOPATH](http://golang.org/doc/code.html#GOPATH) environment variable set. 
- Add the go binary to your $PATH.  If you used brew it'll tell you to do this already.
- `$ go get github.com/stuartnelson3/golang-eventsource` to put the event server and its dependencies in your $GOPATH

If you don't want to use Foreman as described in the section below, you can always run the event source server manually:
`$ PORT=8080 TOKEN=token123 go run server.go`

By default, the eventsource server checks every request for a token that matches against its `$TOKEN` environment variable. Tahi's default token is `token123`. To change this behavior, set the `ES_TOKEN` environment variable for tahi.

By default, tahi attempts to connect to a stream server at `http://localhost:8080`. To change this behavior, set the `ES_URL` environment variable for tahi. There is an event stream server up on heroku:

```
ES_URL=http://tahi-eventsource.herokuapp.com rails s
```

### Running the server

- We're using Foreman to run everything in dev.  Run `bin/fs` to start the server with the correct Procfile.

### Running specs

We use:

- RSpec for unit and integration specs
- Capybara and Selenium
- Qunit and Teaspoon for JavaScript specs
- ember-qunit for ember-specific tests.

In the project directory, running `rspec` will run all unit and integration
specs. Firefox will pop up to run integration tests.

You can run the javascript specs via the command line with `rake teaspoon`.  If you have the rails server
running you can run the specs from `localhost:3000/teaspoon`.  The command line tool is more robust but the browser is slightly faster.

We use semaphore for CI.  If you don't have an account you can use `tahiprojectteam@plos.org:Habanero14screw$`

#### Page Objects

When creating fragments, you can pass the context, if you wish to have access to the page the fragment belongs to. You've to pass the context as an option to the fragment on initializing:

```ruby
EditModalFragment.new(find('tr'), context: page)
```

### Making a new task engine

See the wiki for making new tasks. 

### Configuring S3 direct uploads

Ensure that the following environment variables are set:

- `S3_URL=http://your-s3-bucket.amazonaws.com`
- `S3_BUCKET=your-s3-bucket`
- `AWS_ACCESS_KEY=your-aws-access-key-id`
- `AWS_SECRET_KEY=your-aws-secret-key`

Then, you need to configure your s3 bucket for CORS:

1. Download the AWS cli: 
  - Darwin: `brew install awscli`
  - Linux: `sudo pip install awscli`
2. Run the following command from the app's root directory:
```
aws s3api put-bucket-cors --bucket <your s3 bucket> --cors-configuration file://config/services/s3.cors.development.json
```

### Load testing

To wipe and restore performance data in a pristine state on tahi-performance, run the following:
```heroku pgbackups:restore HEROKU_POSTGRESQL_CYAN_URL b001 --app tahi-performance```

A fully loaded database with thousands of records can be found on S3 here:
```/tahi-performance/tahi_performance_backup.sql.zip```

This can be downloaded and loaded locally, if needed.

The following rake task will create a new set of performance test data from scratch using FactoryGirl factories:
```RAILS_ENV=performance bundle exec rake data:load:all```

This will take several days to reconstruct, so you will probably want to use one of the above steps instead.

### Subset Load testing

Subset data contains about 100 users and some associated records.

To wipe and restore performance data in a pristine state on tahi-performance, run the following:
```heroku pgbackups:restore HEROKU_POSTGRESQL_CYAN_URL b002 --app tahi-performance```
