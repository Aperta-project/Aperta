# TAHI

## Development Notes

### Initial Setup

- Clone the repo
- `brew install imagemagick --with-libtiff`
- Most of the javascript for the app is being handled by Bower.  You'll need to
  have node installed
in order to proceed.  `brew install node` and then `npm install bower -g`
- All bower dependencies are found in the `Bowerfile`
- If you're installing new bower components you'll want to read the
  [rails-bower docs](https://github.com/42dev/bower-rails#rake-tasks),
  especially if your components have stylesheets (`rake bower:resolve`)
- You'll need redis.  `brew install redis` is the easiest way to get it.
- Create database user for tahi `createuser -s -r tahi`
- `cp .env-sample .env.development` and then uncomment the environment variables
  in `.env.development`
- copy the sample database config file.
  `cp config/database.yml.sample config/database.yml`

### Setting up the event server

You will need:

- Go (`brew install go` is easiest) with your
  [$GOPATH](http://golang.org/doc/code.html#GOPATH) environment variable set.
- Add the go binary to your $PATH.  If you used brew it'll tell you to do this
  already.
- `$ go get github.com/tahi-project/golang-eventsource` to put the event server
  and its dependencies in your $GOPATH

If you don't want to use Foreman as described in the section below, you can
always run the event source server manually:
`$ PORT=8080 TOKEN=token123 go run server.go`

By default, the eventsource server checks every request for a token that matches
against its `$TOKEN` environment variable. Tahi's default token is `token123`.
To change this behavior, set the `ES_TOKEN` environment variable for tahi.

By default, tahi attempts to connect to a stream server at
`http://localhost:8080`. To change this behavior, set the `ES_URL` environment
variable for tahi:

```
ES_URL=http://your-custom-event-server.example.com rails s
```

### Running the server
- We're using Foreman to run everything in dev.  Run `bin/foreman-start` to
  start the server with the correct Procfile.

### Inserting test data
Run `rake db:setup`. This will delete any data you already have in your
database, and insert test users based on what you see in `db/seeds.rb`.

### Running specs

We use:

- RSpec for unit and integration specs
- Capybara and Selenium
- Qunit and Teaspoon for JavaScript specs
- ember-qunit for ember-specific tests.

In the project directory, running `rspec` will run all unit and integration
specs. Firefox will pop up to run integration tests.

You can run the javascript specs via the command line with `rake teaspoon`.  If
you have the rails server running you can run the specs from
`localhost:5000/qunit`.  The command line tool is more robust but the browser is
slightly faster.

#### Page Objects

When creating fragments, you can pass the context, if you wish to have access to
the page the fragment belongs to. You've to pass the context as an option to the
fragment on initializing:

```ruby
EditModalFragment.new(find('tr'), context: page)
```

### Configuring S3 direct uploads

Get access to S3 and make a new IAM user, for security reasons. Then take these
keys and use them. (If someone has already set this up, reuse their keys).

Ensure that the following environment variables are set:

- `S3_URL=http://your-s3-bucket.amazonaws.com`
- `S3_BUCKET=your-s3-bucket`
- `AWS_ACCESS_KEY=your-aws-access-key-id`
- `AWS_SECRET_KEY=your-aws-secret-key`
- `AWS_REGION=us-west-1` or us-east-1, etc.

Then, you need to configure your s3 bucket for CORS:

1. Download the AWS cli:
  - Darwin: `brew install awscli`
  - Linux: `sudo pip install awscli`
2. Run the following command from the app's root directory:
```
aws s3api put-bucket-cors --bucket <your s3 bucket> --cors-configuration file://config/services/s3.cors.development.json
```

### Load testing

To wipe and restore performance data in a pristine state on tahi-performance,
run the following:
```
heroku pgbackups:restore HEROKU_POSTGRESQL_CYAN_URL b001 --app tahi-performance
```

A fully loaded database with thousands of records can be found on S3 here:
```tahi-performance/tahi_performance_backup.sql.zip ```

This can be downloaded and loaded locally, if needed.

The following rake task will create a new set of performance test data from scratch using FactoryGirl factories:
```RAILS_ENV=performance bundle exec rake data:load:all```

This will take several days to reconstruct, so you will probably want to use one of the above steps instead.

### Subset Load testing

Subset data contains about 100 users and some associated records.

To wipe and restore performance data in a pristine state on tahi-performance,
run the following:
```heroku pgbackups:restore HEROKU_POSTGRESQL_CYAN_URL b002 --app tahi-performance```

### Sunspot Solr Search

If you are going to be using the search functionality, make sure to reindex the
database while the server is running with:
```rake sunspot:solr:reindex```

### Postgres Backups

Backups should be run automatically every day. If you would like to run one
manually run ```heroku pgbackups:capture```

You can get the URL to download a backup by running ```heroku pgbackups:url```

To list current backups ```heroku pgbackups```

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

```heroku pgbackups:restore HEROKUPOSTGRESQL_ROSE_URL b020```
