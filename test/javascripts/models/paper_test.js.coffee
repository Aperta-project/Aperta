#= require test_helper

moduleForModel 'paper', 'Unit: Paper Model',
  needs: ['model:user', 'model:figure', 'model:journal', 'model:phase', 'model:task', 'model:comment']

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

test 'allTasks returns all tasks for the paper', ->
  task1 = null; task2 = null
  allTasks = Ember.run =>
    paper = @store().createRecord 'paper',
      title: 'title'
      shortTitle: 'short title'
    phase = @store().createRecord 'phase',
      paper: paper

    task1 = @store().createRecord 'task',
      title: 'task1'
      phase: phase

    task2 = @store().createRecord 'task',
      title: 'task2'
      phase: phase

    paper.setProperties phase: phase
    paper.get 'allTasks'

  deepEqual allTasks.mapBy('title'), [task1.get('title'), task2.get('title')]

test 'Paper hasMany assignees as User', ->
  relationships = Ember.get ETahi.Paper, 'relationships'
  assigneeRelation = _.detect relationships.get(ETahi.User), (relationship) ->
    relationship.name == 'assignees'

  deepEqual assigneeRelation, { name: "assignees", kind: "hasMany" }

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
