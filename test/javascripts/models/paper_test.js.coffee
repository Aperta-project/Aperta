moduleForModel 'paper', 'Unit: Paper Model',
  needs: ['model:author', 'model:user', 'model:figure', 'model:journal',
  'model:questionAttachment', 'model:commentLook', 'model:attachable', 'model:affiliation',
  'model:supportingInformationFile', 'model:phase', 'model:task', 'model:comment', 'model:participation',
  'model:litePaper', 'model:cardThumbnail', 'model:question', 'model:collaboration', 'model:attachment']
  setup: -> setupApp()
  teardown: -> ETahi.reset()

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

test 'Paper hasMany editors as User', ->
  relationships = Ember.get ETahi.Paper, 'relationships'
  editorsRelation = _.detect relationships.get(ETahi.User), (relationship) ->
    relationship.name == 'editors'

  deepEqual editorsRelation, { name: "editors", kind: "hasMany" }

test 'Paper hasMany reviewers as User', ->
  relationships = Ember.get ETahi.Paper, 'relationships'
  reviewersRelation = _.detect relationships.get(ETahi.User), (relationship) ->
    relationship.name == 'reviewers'

  deepEqual reviewersRelation, { name: "reviewers", kind: "hasMany" }

test 'Paper hasMany figures', ->
  relationships = Ember.get ETahi.Paper, 'relationships'
  deepEqual relationships.get(ETahi.Figure)[0], { name: "figures", kind: "hasMany" }

test 'Paper hasMany phases', ->
  relationships = Ember.get ETahi.Paper, 'relationships'
  deepEqual relationships.get(ETahi.Phase)[0], { name: "phases", kind: "hasMany" }

test 'Paper belongsTo Journal', ->
  relationships = Ember.get ETahi.Paper, 'relationships'
  deepEqual relationships.get(ETahi.Journal)[0], { name: "journal", kind: "belongsTo" }
