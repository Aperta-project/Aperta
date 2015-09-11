`import Ember from 'ember'`
`import { test, moduleForModel } from 'ember-qunit'`
`import startApp from 'tahi/tests/helpers/start-app'`
`import FactoryGuy from 'ember-data-factory-guy'`
`import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper'`

App = undefined
paper = undefined
phase = undefined

moduleForModel 'paper', 'Unit: Paper Model',
  needs: ['model:user', 'model:figure', 'model:table', 'model:bibitem',
    'model:journal',
    'model:decision', 'model:invitation', 'model:affiliation', 'model:attachment',
    'model:question-attachment', 'model:comment-look',
    'model:phase', 'model:task', 'model:comment', 'model:participation',
    'model:card-thumbnail', 'model:question', 'model:nested-question',
    'model:nested-question-answer', 'model:collaboration',
    'model:supporting-information-file']

  afterEach: ->
    Ember.run ->
      TestHelper.teardown()
    Ember.run(App, "destroy")

  beforeEach: ->
    App = startApp()
    TestHelper.setup(App)


test 'displayTitle displays short title if title is missing', (assert) ->
  shortTitle = 'test short title'
  paper = FactoryGuy.make("paper", title: "", shortTitle: shortTitle)
  assert.equal paper.get('displayTitle'), shortTitle

test 'displayTitle displays title if present', (assert) ->
  title = 'Test Title'
  paper = FactoryGuy.make("paper", title: title, shortTitle: "")
  assert.equal paper.get('displayTitle'), title

test 'allSubmissionTasks filters tasks by isSubmissionTask', (assert) ->
  phase = FactoryGuy.make("phase")
  notSubmissionTask = FactoryGuy.make("task", { phase: phase, title: "Not submission", isSubmissionTask: false })
  submissionTask = FactoryGuy.make("task", { phase: phase, title: "Submission", isSubmissionTask: true })
  paper = FactoryGuy.make("paper", phases: [phase], tasks: [notSubmissionTask, submissionTask])
  assert.deepEqual paper.get('allSubmissionTasks').mapBy("title"), [submissionTask.get('title')]
