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

module "Integration: inviting an editor",

  teardown: ->
    Ember.run ->
      testHelper.teardown()
      app.destroy()

  setup: ->
    app = startApp()
    testHelper = TestHelper.setup(app)
    setupFactories()

    $.mockjax(url: "/admin/journals/authorization", status: 204)
    $.mockjax(url: "/user_flows/authorization", status: 204)
    $.mockjax
      url: "/formats"
      status: 200
      responseText:
        "export_formats": [{ "format": "docx" }, { "format": "latex" }]
        "import_formats": [{ "format": "docx" }, { "format": "odt" }]
    $.mockjax
      url: /\/papers\/\d+\/manuscript_manager/
      status: 204
      contentType: "application/html"
      headers: { 'tahi-authorization-check': true }
      responseText: ""

    $.mockjax
      url: /filtered_users/
      status: 200
      contentType: "application/json"
      responseText:
        filtered_users: [{ id: 1, full_name: "Aaron", email: "aaron@neo.com" }]

    phase = FactoryGuy.make("phase")
    task = FactoryGuy.make("paper-editor-task", { phase: phase })
    paper = FactoryGuy.make('paper', { phases: [phase], tasks: [task] })

test "displays the email of the invitee", ->
  $.mockjax
    url: /filtered_users/
    status: 200
    contentType: "application/json"
    responseText:
      filtered_users: [{ id: 1, full_name: "Aaron", email: "aaron@neo.com" }]

  testHelper.handleCreate("invitation")

  visit("/papers/#{paper.id}/manage")
  click("#manuscript-manager .card-content:contains('Assign Editors')")
  pickFromSelect2(".overlay-main-work", "aaron@neo.com")
  click(".invite-editor-button")

  andThen ->
    ok(find(".overlay-main-work:contains('aaron@neo.com has been invited to be Editor on this manuscript.')"))

test "can withdrawl the invitation", ->
  invitation = FactoryGuy.make("invitation", email: "foo@bar.com")
  Ember.run =>
    task.set("invitation", invitation)

  visit("/papers/#{paper.id}/manage")
  click("#manuscript-manager .card-content:contains('Assign Editors')")
  ok(find(".invite-editor-task:contains('foo@bar.com has been invited to be Editor on this manuscript.')"), "has pending invitation")

  $.mockjax
    proxyType: "DELETE"
    url: "/invitations/#{invitation.get('id')}"
    status: 204

  click(".button-primary:contains('Withdraw invitation')")

  andThen ->
    equal(task.get('invitation'), null)
