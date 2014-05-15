# TAHI

## Development Notes

### Initial Setup

- Clone the repo
- Most of the javascript for the app is being handled by Bower.  You'll need to have node installed
in order to proceed.  `brew install node` and then `npm install bower -g`
- All bower dependencies are found in the `Bowerfile`
- If you're installing new bower components you'll want to read the [rails-bower docs](https://github.com/42dev/bower-rails#rake-tasks), especially if 
your components have stylesheets (`rake bower:resolve`)

### Setting up the event server

You will need:
- Go with your $GOPATH environment variable set.
- a cloned copy of https://github.com/stuartnelson3/golang-eventsource: 
  `$ git clone git@github.com:stuartnelson3/golang-eventsource.git`

From your golang-eventsource folder:

Download your server dependencies
```
$ for f in github.com/antage/eventsource/http github.com/martini-contrib/cors github.com/codegangsta/martini; do
  go get $f
  done
```

Run your server
`$ PORT=8080 TOKEN=token123 go run server.go`

By default, the eventsource server checks every request for a token that matches against its `$TOKEN` environment variable. Tahi's default token is `token123`. To change this behavior, set the `ES_TOKEN` environment variable for tahi.

By default, tahi attempts to connect to a stream server at `http://localhost:8080`. To change this behavior, set the `ES_URL` environment variable for tahi. There is an event stream server up on heroku:

```
ES_URL=http://tahi-eventsource.herokuapp.com rails s
```

Or alternatively, create a `.env.development` file with this (and any other) envrionment variables, and it will be loaded automatically.  See `.env-sample` for more information.

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
Rails still compiles assets between every test run.
