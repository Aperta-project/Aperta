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

### We precompile assets

As of the time of this writing, the enironment Heroku uses to precompile assets
for Rails apps uses Node 0.4. This version of Node has issues compiling JSX. As
a result, we precompile our assets and check them in. A typical workflow looks
like this:

```bash
$ bin/precompile-assets.sh
$ git status
$ git add -A
$ git commit
```

There is also a pre-commit hook which checks whether assets need compiling. To
install the commit hook, run this in the project directory:

```bash
$ ln -snf bin/asset-pipeline-precommit .git/hooks/pre-commit
```

There's a [Github issue for React][react-issue] documenting this problem. It
looks like React is taking steps to fix this, so hopefully this won't be
necessary for much longer.

[react-issue]: https://github.com/facebook/react-rails/issues/9
