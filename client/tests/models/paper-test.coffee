`import Ember from 'ember'`
`import { test, moduleForModel } from 'ember-qunit'`

moduleForModel 'paper', 'Unit: Paper Model',
  needs: ['model:author', 'model:user', 'model:figure', 'model:table', 'model:bibitem',
    'model:journal',
    'model:decision', 'model:invitation', 'model:affiliation', 'model:attachment',
    'model:question-attachment', 'model:comment-look',
    'model:phase', 'model:task', 'model:comment', 'model:participation',
    'model:card-thumbnail', 'model:question', 'model:nested-question',
    'model:nested-question-answer', 'model:collaboration',
    'model:supporting-information-file']

test 'displayTitle displays short title if title is missing', (assert) ->
  shortTitle = 'test short title'

  paper = Ember.run =>
    paper = @store().createRecord 'paper',
      title: ''
      shortTitle: shortTitle

  assert.equal paper.get('displayTitle'), shortTitle

test 'displayTitle displays title if present', (assert) ->
  title = 'Test Title'

  paper = Ember.run =>
    @store().createRecord 'paper',
      title: title
      shortTitle: 'test short title'

  assert.equal paper.get('displayTitle'), title

test 'Paper hasMany tasks (async)', (assert) ->
  stop()
  paperPromise = Ember.run =>
    task1 = @store().createRecord 'task', type: 'Task', title: 'A message', isMetadataTask: false
    task2 = @store().createRecord 'task', type: 'InitialTechCheckTask', title: 'some task',isMetadataTask: true
    paper = @store().createRecord 'paper',
      title: 'some really long title'
      shortTitle: 'test short title'
    paper.get('tasks').then (tasks) ->
      tasks.pushObjects [task1, task2]
      paper

  paperPromise.then((paper) ->
    assert.deepEqual paper.get('tasks').mapBy('type'), ['Task', 'InitialTechCheckTask']
  ).then(start, start)


test 'allSubmissionTasks filters tasks by isSubmissionTask', (assert) ->
  stop()
  paperPromise = Ember.run =>
    task1 = @store().createRecord 'task', type: 'Task', title: 'A message', isSubmissionTask: false
    task2 = @store().createRecord 'task', type: 'InitialTechCheckTask', title: 'some task',isSubmissionTask: true
    paper = @store().createRecord 'paper',
      title: 'some really long title'
      shortTitle: 'test short title'
    paper.get('tasks').then (tasks) ->
      tasks.pushObjects [task1, task2]
      paper

  paperPromise.then((paper) ->
    assert.deepEqual paper.get('allSubmissionTasks').mapBy('type'), ['InitialTechCheckTask']
  ).then(start, start)
