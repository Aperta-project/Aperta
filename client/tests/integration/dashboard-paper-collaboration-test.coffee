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

  teardown: ->
    Ember.run ->
      TestHelper.teardown()
      App.destroy()

  setup: ->
    App = startApp()
    TestHelper.setup(App)
    $.mockjax(url: "/api/admin/journals/authorization", status: 204)
    $.mockjax(url: "/api/user_flows/authorization", status: 204)


test 'The dashboard shows papers for a user if they have any role on the paper', ->
  Ember.run ->
    TestHelper.handleFindAll("comment-look", 0)
    TestHelper.handleFindAll("invitation", 0)
    TestHelper.handleFindAll("paper", 6, "withRoles")

    visit('/')

    andThen ->
      equal find('.dashboard-submitted-papers .dashboard-paper-title').length, 6, 'All papers with roles should be visible'

test 'The dashboard shows paginated papers', ->
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
      ok(find('.load-more-papers').length, "sees load more button")
      ok(Ember.isPresent(find('.welcome-message').text().match("You have #{perPage + extra} manuscripts")), "sees welcome message")
      equal(find('.dashboard-submitted-papers .dashboard-paper-title').length, perPage, "num papers per page")

    andThen ->
      morePapers = FactoryGuy.makeList("paper", extra, "withRoles")
      TestHelper.handleFindQuery("paper", ["page_number"], morePapers)

      click '.load-more-papers'

    andThen ->
      equal(find('.dashboard-submitted-papers .dashboard-paper-title').length, perPage + extra, "paginated result count")
      ok(!find('.load-more-papers').length, "no longer sees load more button")

test 'Adding and removing papers via the event stream', ->
  Ember.run ->
    paperCount = 1
    TestHelper.handleFindAll("comment-look", 0)
    TestHelper.handleFindAll("invitation", 0)
    TestHelper.handleFindAll("paper", paperCount, "withRoles")

    visit('/')

    [es, store] = setupEventStream()

    andThen ->
      Ember.run ->
        data = Ember.merge({ paper: FactoryGuy.build("paper", "withRoles")}, { action: "created" })
        es.msgResponse(data)

        andThen ->
          equal find('.dashboard-submitted-papers .dashboard-paper-title').length, paperCount+1, "paper added via event stream"

    andThen ->
      Ember.run ->
        paper = store.all("paper").objectAt(0)
        data = {
          action: "destroyed",
          type: "papers",
          ids: [paper.get("id")]
        }
        es.msgResponse(data)

        andThen ->
          equal find('.dashboard-submitted-papers .dashboard-paper-title').length, paperCount, "paper removed via event stream"
