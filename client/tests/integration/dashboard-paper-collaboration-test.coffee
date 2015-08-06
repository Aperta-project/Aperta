`import Ember from 'ember'`
`import startApp from '../helpers/start-app'`
`import { module, test } from 'qunit'`
`import FactoryGuy from 'ember-data-factory-guy'`
`import TestHelper from "ember-data-factory-guy/factory-guy-test-helper"`

App = null

setupEventStream = ->
  store = getStore()
  es = EventStream.create
    store: store
    init: ->
  [es, store]


module 'Integration: Dashboard Collaboration',

  afterEach: ->
    Ember.run(-> TestHelper.teardown() )
    Ember.run(App, App.destroy)

  beforeEach: ->
    App = startApp()
    TestHelper.setup(App)
    $.mockjax(url: "/api/admin/journals/authorization", status: 204)
    $.mockjax(url: "/api/user_flows/authorization", status: 204)

test 'The dashboard shows papers for a user if they have any role on the paper', (assert) ->
  Ember.run ->
    TestHelper.handleFindAll("comment-look", 0)
    TestHelper.handleFindAll("invitation", 0)
    TestHelper.handleFindAll("paper", 6, "withRoles")

    visit('/')

    andThen ->
      assert.equal find('.dashboard-submitted-papers .dashboard-paper-title').length, 6, 'All papers with roles should be visible'

test 'The dashboard shows paginated papers', (assert) ->
  perPage =  15
  extra = 2
  Ember.run ->
    TestHelper.handleFindAll("comment-look", 0)
    TestHelper.handleFindAll("invitation", 0)
    TestHelper.handleFindAll("paper", perPage, "withRoles")

    getStore().metadataFor("paper")["total_pages"] = 2
    getStore().metadataFor("paper")["total_papers"] = 17

    visit '/'

    andThen ->
      assert.ok(find('.load-more-papers').length, "sees load more button")
      assert.ok(Ember.isPresent(find('.welcome-message').text().match("You have #{perPage + extra} manuscripts")), "sees welcome message")
      assert.equal(find('.dashboard-submitted-papers .dashboard-paper-title').length, perPage, "num papers per page")

    andThen ->
      morePapers = FactoryGuy.makeList("paper", extra, "withRoles")
      TestHelper.handleFindQuery("paper", ["page_number"], morePapers)

      click '.load-more-papers'

    andThen ->
      equal(find('.dashboard-submitted-papers .dashboard-paper-title').length, perPage + extra, "paginated result count")
      assert.ok(!find('.load-more-papers').length, "no longer sees load more button")
