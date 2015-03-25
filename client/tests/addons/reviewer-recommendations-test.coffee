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

module "Integration: Reviewer Recommendations",
  teardown: ->
    Ember.run ->
      testHelper.teardown()
      app.destroy()

  setup: ->
    app = startApp()
    testHelper = TestHelper.setup app

    phase = FactoryGuy.make "phase"
    task = FactoryGuy.make "reviewer-recommendations-task", phase: phase
    paper = FactoryGuy.make "paper", { phases: [phase], tasks: [task] }

test "contains the correct task title and forms", ->
  visit "/papers/#{paper.id}/manage"
  click "#manuscript-manager .card-content:contains('Reviewer Recommendations')"
  andThen ->
    ok find('.overlay-main-work h1').text().trim(), 'Reviewer Recommendations'
    ok find('.question-list .question').length > 0
    # ok find('.helper-text').text().trim().match /suggest potential reviewers/
    # ok find('.reviewer-recommendation-form label').length > 0
