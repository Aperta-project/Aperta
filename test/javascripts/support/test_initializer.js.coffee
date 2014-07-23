#= require support/mock_server
#= require support/factories

document.write('<div id="ember-testing-container"><div id="ember-testing"></div></div>')
document.write('<style>#ember-testing-container { position: absolute; background: white; bottom: 0; right: 0; width: 640px; height: 384px; overflow: auto; z-index: 9999; border: 1px solid #ccc; } #ember-testing { zoom: 50%; }</style>');

Ember.Test.registerHelper('pushModel', (app, type, data) ->
  store = app.__container__.lookup('store:main')
  Ember.run ->
    store.push(type, data)
    store.getById(type, data.id)
)

Ember.Test.registerHelper('pushPayload', (app, type, data) ->
  store = app.__container__.lookup('store:main')
  Ember.run ->
    store.pushPayload(type, data)
)

Ember.Test.registerHelper('getStore', (app) ->
  app.__container__.lookup('store:main')
)

# All interactions with ember are while a user is signed in
@currentUserId = 183475
@fakeUser =
  affiliations: []
  user:
    id: @currentUserId
    full_name: "Fake User"
    avatar_url: "/images/profile-no-image.png"
    username: "fakeuser"
    email: "fakeuser@example.com"
    admin: false
    affiliation_ids: []

@setupTestEnvironment = ->
  @setupMockServer()
  emq.globalize()
  setResolver Ember.DefaultResolver.create namespace: ETahi
  Em.run ->
    ETahi.rootElement = '#ember-testing'
    ETahi.setupForTesting()
    ETahi.injectTestHelpers()

@setupTestEnvironment()

@setupApp = (options={integration:false}) ->
  window.TahiTest = {} # for storing test variables
  if options.integration
    @setupTestEnvironment()

    container = ETahi.__container__
    applicationController = container.lookup('controller:application')

    store = container.lookup 'store:main'
    store.find 'user', @currentUserId
    .then (currentUser) -> applicationController.set 'currentUser', currentUser
  else
    emq.globalize()
    setResolver Ember.DefaultResolver.create namespace: ETahi
    ETahi.setupForTesting()
