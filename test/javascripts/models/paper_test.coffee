#= require test_helper

moduleForModel 'paper', 'Unit: Paper Model',
  needs: ['model:user', 'model:declaration', 'model:figure', 'model:journal', 'model:phase']
  setup: ->
    # beforeEach
    # Ember.run ETahi, ETahi.advanceReadiness
  teardown: ->
    # afterEach
    # ETahi.reset()

test 'displayTitle displays short title if title is missing', ->
  paper = null
  shortTitle = 'test short title'

  Ember.run =>
    paper = @store().createRecord 'paper',
      title: ''
      shortTitle: shortTitle

  equal paper.get('displayTitle'), shortTitle

test 'displayTitle displays title if present', ->
  paper = null
  title = 'Test Title'

  Ember.run =>
    paper = @store().createRecord 'paper',
      title: title
      shortTitle: 'test short title'

  equal paper.get('displayTitle'), title

test 'Paper hasMany assignees as User', ->
  relationships = Ember.get ETahi.Paper, 'relationships'
  assigneeRelation = _.detect relationships.get(ETahi.User), (relationship) ->
    relationship.name == 'assignees'

  deepEqual assigneeRelation, { name: "assignees", kind: "hasMany" }

test 'Paper hasMany editors as User', ->
  relationships = Ember.get ETahi.Paper, 'relationships'
  assigneeRelation = _.detect relationships.get(ETahi.User), (relationship) ->
    relationship.name == 'editors'

  deepEqual assigneeRelation, { name: "editors", kind: "hasMany" }

test 'Paper hasMany reviewers as User', ->
  relationships = Ember.get ETahi.Paper, 'relationships'
  assigneeRelation = _.detect relationships.get(ETahi.User), (relationship) ->
    relationship.name == 'reviewers'

  deepEqual assigneeRelation, { name: "reviewers", kind: "hasMany" }

test 'Paper hasMany declarations', ->
  relationships = Ember.get ETahi.Paper, 'relationships'
  deepEqual relationships.get(ETahi.Declaration)[0], { name: "declarations", kind: "hasMany" }

test 'Paper hasMany figures', ->
  relationships = Ember.get ETahi.Paper, 'relationships'
  deepEqual relationships.get(ETahi.Figure)[0], { name: "figures", kind: "hasMany" }

test 'Paper hasMany phases', ->
  relationships = Ember.get ETahi.Paper, 'relationships'
  deepEqual relationships.get(ETahi.Phase)[0], { name: "phases", kind: "hasMany" }

test 'Paper belongsTo Journal', ->
  relationships = Ember.get ETahi.Paper, 'relationships'
  deepEqual relationships.get(ETahi.Journal)[0], { name: "journal", kind: "belongsTo" }


