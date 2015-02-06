#= require support/mock_server
#= require support/factories
#= require_directory ./setups/
document.write('<div id="ember-testing-container"><div id="ember-testing"></div></div>')
document.write('<style>#ember-testing-container { position: absolute; background: white; bottom: 0; right: 0; width: 640px; height: 384px; overflow: auto; z-index: 9999; border: 1px solid #ccc; } #ember-testing { zoom: 50%; }</style>');

Ember.Test.registerHelper('assertText', (app, selector, text) ->
  ok Em.$.trim(find(selector).text()).indexOf(text) isnt -1, "it should have text: #{text} within #{selector}"
)

Ember.Test.registerHelper('assertNoText', (app, selector, text) ->
  ok Em.$.trim(find(selector).text()).indexOf(text) is -1, "it should not have text: #{text} within #{selector}"
)

Ember.Test.registerAsyncHelper('pickFromChosenSingle', (app, selector, choice) ->
  click ".chosen-container#{selector} a.chosen-single"
  click "li.active-result:contains('#{choice}')"
)

QUnit.testDone(-> ETahi.Factory.resetFactoryIds())
# All interactions with ember are while a user is signed in
@currentUserId = 1
@fakeUser = ETahi.Factory.createRecord 'User',
  id: @currentUserId
  full_name: "Fake User"
  username: "fakeuser"
  email: "fakeuser@example.com"

@teaspoonTesting = true
@setupTestEnvironment = ->
  @setupMockServer()
  emq.globalize()
  setResolver Ember.DefaultResolver.create namespace: ETahi
  ETahi.rootElement = '#ember-testing'
  ETahi.setupForTesting()
  ETahi.injectTestHelpers()
  window.ETahi.environment = 'test'

@setupTestEnvironment()

@setupApp = (options={integration:false}) ->
  window.TahiTest = {} # for storing test variables
  if options.integration
    container = ETahi.__container__
    applicationController = container.lookup('controller:application')

    store = container.lookup 'store:main'
    store.find 'user', @currentUserId
    .then (currentUser) -> applicationController.set 'currentUser', currentUser
