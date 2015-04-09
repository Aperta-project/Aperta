`import Ember from 'ember'`
`import { test, moduleForModel } from 'ember-qunit'`

moduleForModel 'paper', 'Unit: Paper Model',
  needs: ['model:author', 'model:user', 'model:figure', 'model:journal',
    'model:question-attachment', 'model:comment-look', 'model:attachable', 'model:affiliation',
    'model:phase', 'model:task', 'model:comment', 'model:participation',
    'model:lite-paper', 'model:card-thumbnail', 'model:question', 'model:collaboration', 'model:attachment',
    'model:supporting-information-file', 'model:event']

test 'displayTitle displays short title if title is missing', ->
  shortTitle = 'test short title'

  paper = Ember.run =>
    paper = @store().createRecord 'paper',
      title: ''
      shortTitle: shortTitle

  equal paper.get('displayTitle'), shortTitle

test 'displayTitle displays title if present', ->
  title = 'Test Title'

  paper = Ember.run =>
    @store().createRecord 'paper',
      title: title
      shortTitle: 'test short title'

  equal paper.get('displayTitle'), title

test 'Paper hasMany tasks (async)', ->
  stop()
  paperPromise = Ember.run =>
    task1 = @store().createRecord 'task', type: 'Task', title: 'A message', isMetadataTask: false
    task2 = @store().createRecord 'task', type: 'TechCheckTask', title: 'some task',isMetadataTask: true
    paper = @store().createRecord 'paper',
      title: 'some really long title'
      shortTitle: 'test short title'
    paper.get('tasks').then (tasks) ->
      tasks.pushObjects [task1, task2]
      paper

  paperPromise.then((paper) ->
    deepEqual paper.get('tasks').mapBy('type'), ['Task', 'TechCheckTask']
  ).then(start, start)


test 'allMetadata tasks filters tasks by isMetaData', ->
  stop()
  paperPromise = Ember.run =>
    task1 = @store().createRecord 'task', type: 'Task', title: 'A message', isMetadataTask: false
    task2 = @store().createRecord 'task', type: 'TechCheckTask', title: 'some task',isMetadataTask: true
    paper = @store().createRecord 'paper',
      title: 'some really long title'
      shortTitle: 'test short title'
    paper.get('tasks').then (tasks) ->
      tasks.pushObjects [task1, task2]
      paper

  paperPromise.then((paper) ->
    deepEqual paper.get('allMetadataTasks').mapBy('type'), ['TechCheckTask']
  ).then(start, start)

