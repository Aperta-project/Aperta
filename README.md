# TAHI

## Development Notes

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

### Running specs

We use:

- RSpec for unit and integrations specs
- Capybara to drive the web browser in integration specs
- Jasmine for JavaScript specs

In the project directory, running `rspec` will run all unit and integration
specs. Firefox will pop up to run integration tests. We used to run integration
specs with capybara-webkit but that broke for us when we introduced `pushState`
for cards.

In order to run Jasmine specs in the browser, first start the Jasmine server
with `rake jasmine`. Running the Jasmine specs headless requires RAILS_ENV to be
`test`. Jasmine runs headless specs in PhantomJS which doesn't support
`Function.prototype.bind`, heavily used by React. The test environment loads a
polyfill (see [polyfills.js.erb in the repo][polyfill]).

[polyfill]: https://github.com/Tahi-project/tahi/blob/master/app/assets/javascripts/polyfills.js.erb
