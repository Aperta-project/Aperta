#= require support/mock_server

document.write('<div id="ember-testing-container"><div id="ember-testing"></div></div>')
document.write('<style>#ember-testing-container { position: absolute; background: white; bottom: 0; right: 0; width: 640px; height: 384px; overflow: auto; z-index: 9999; border: 1px solid #ccc; } #ember-testing { zoom: 50%; }</style>');

# All interactions with ember are while a user is signed in
TahiTest = {}
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
