# TAHI

## Development Notes

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
