`import Ember from "ember";`
`import startApp from "../helpers/start-app";`
`import FactoryGuy from "factory-guy";`
`import { test } from "ember-qunit";`
`import { testMixin as FactoryGuyTestMixin } from "factory-guy";`
`import setupFactories from "../helpers/factories";`

TestHelper = Ember.Object.createWithMixins(FactoryGuyTestMixin)

app = null
paper = null
task = null
testHelper = null

setupFactories()

module "Integration: adding an author",

  teardown: ->
    Ember.run ->
      testHelper.teardown()
      app.destroy()

  setup: ->
    app = startApp()
    testHelper = TestHelper.setup(app)

    $.mockjax(url: "/api/admin/journals/authorization", status: 204)
    $.mockjax(url: "/api/user_flows/authorization", status: 204)
    $.mockjax(url: "/api/affiliations", status: 200, responseText: [])

    phase = FactoryGuy.make("phase")
    task = FactoryGuy.make("plos-authors-task", { phase: phase })
    paper = FactoryGuy.make('paper', { phases: [phase], tasks: [task], editable: true })

    $.mockjax
      url: "/api/plos_authors"
      status: 201
      responseText: {
        plos_authors:[
          {
            id:4,
            first_name:'James',
            position:1,
            paper_id:paper.id,
            plos_authors_task_id:task.id
          }
        ]
      }

test "can add a new author", ->
  visit("/papers/#{paper.id}/tasks/#{task.id}")
  click(".button-primary:contains('Add a New Author')")
  fillIn(".author-name input:first", "James")
  click(".author-contributions input:first")
  click(".author-form-buttons .button-secondary:contains('done')")
  andThen ->
    ok(find(".authors-overlay-item .author-name:contains('James')"))
