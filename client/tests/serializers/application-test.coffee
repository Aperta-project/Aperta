`import Ember from 'ember'`
`import DS from 'ember-data'`
`import startApp from '../helpers/start-app'`
`import { test, moduleFor } from 'ember-qunit'`

subject = null
container = null

module 'integration/serializer',
  setup: ->
    app = startApp()
    container = app.__container__
    subject = container.lookup('serializer:application')

test 'normalizeType denamespaces task types', ->
  result = subject.normalizeType({type: 'Foo::BarTask'})
  equal result.qualified_type, 'Foo::BarTask', 'saves the original type as qualified_type'
  equal result.type, 'BarTask', 'strips the namespace off the type'

test 'serializing a model that was originally namespaced will correctly re-namespace it', ->
  Ember.run =>
    task = getStore().createRecord('task', qualifiedType: "Foo::BarTask")
    json = subject.serialize(task)
    equal json.type, "Foo::BarTask"
    equal undefined, json.qualified_type, 'deletes qualified_type from the payload'

test 'has a custom extractTypeName function to make things easier', ->
  hashType = subject.extractTypeName('foo', {type: 'bar'})
  equal hashType, 'bar', 'extracts the type from the hash if it exists'

  propType = subject.extractTypeName('cow', {otherStuff: 'whoah'})
  equal propType, 'cow', 'uses the prop for the typeName otherwise'

test "extractSingle puts sideloaded things into the store via their 'type' attribute", ->
  TechCheckTask = DS.Model.extend
    title: DS.attr('string')
    type: DS.attr('string')
  PlosAuthorsTask = DS.Model.extend
    title: DS.attr('string')
    type: DS.attr('string')

  store = getStore()
  container.register("model:tech-check-task", TechCheckTask)
  container.register("model:plos-authors-task", PlosAuthorsTask)

  jsonHash =
    tasks:
      [ {id: '1', type: 'TechCheckTask', title: 'Tech Check'}
        {id: '2', type: 'Foo::PlosAuthorsTask', title: 'Check Authors'}
      ]
    phase:
      id: '1'
      tasks: [{id: '1', type: 'TechCheckTask'}, {id: '2', type: 'PlosAuthorsTask'}]

  Ember.run ->
    result = subject.extractSingle(store, store.modelFor('phase'), jsonHash)
    equal store.getById('task', 1), null, 'no Task gets pushed into the store'
    store.find('techCheckTask', 1).then (task) ->
      equal task.get('title'), 'Tech Check', 'the message task is in the store'
    store.find('plosAuthorsTask', 2).then (task) ->
      equal task.get('title'), 'Check Authors', 'the namespaced authors task is in the store'

test "extractMany puts normalizes things via their 'type' attribute", ->
  PaperEditorTask = DS.Model.extend
    title: DS.attr('string')
    type: DS.attr('string')
    uniqueProperty: DS.attr('string')

  store = getStore()
  container.register("model:paper-editor-task", PaperEditorTask)

  jsonHash =
    users: [{id: '1', username: 'editorGuy'}]
    tasks: [{id: '1', type: 'PaperEditorTask', title: 'Edit Stuff', unique_property: "foo" }]

  Ember.run ->
    result = subject.extractArray(store, store.modelFor('task'), jsonHash)
    ok result[0].unique_property
