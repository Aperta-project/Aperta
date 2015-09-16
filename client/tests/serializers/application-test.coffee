`import Ember from 'ember'`
`import DS from 'ember-data'`
`import startApp from '../helpers/start-app'`
`import { test, moduleFor } from 'ember-qunit'`

subject = null
container = null

module 'integration/serializer',
  beforeEach: ->
    app = startApp()
    container = app.__container__
    subject = container.lookup('serializer:application')

test 'normalizeType denamespaces task types', (assert) ->
  result = subject.normalizeType({type: 'Foo::BarTask'})
  assert.equal result.qualified_type, 'Foo::BarTask', 'saves the original type as qualified_type'
  assert.equal result.type, 'BarTask', 'strips the namespace off the type'

test 'normalizeType denamespaces deeply namespaced task types', (assert) ->
  result = subject.normalizeType({type: 'Foo::Baz::BarTask'})
  assert.equal result.qualified_type, 'Foo::Baz::BarTask', 'saves the original type as qualified_type'
  assert.equal result.type, 'BarTask', 'strips the namespace off the type'

test 'normalizeType denamespaces really deeply namespaced task types', (assert) ->
  result = subject.normalizeType({type: 'Tahi::Foo::Baz::BarTask'})
  assert.equal result.qualified_type, 'Tahi::Foo::Baz::BarTask', 'saves the original type as qualified_type'
  assert.equal result.type, 'BarTask', 'strips the namespace off the type'

test 'serializing a model that was originally namespaced will correctly re-namespace it', (assert) ->
  Ember.run =>
    task = getStore().createRecord('task', qualifiedType: 'Foo::BarTask')
    snapshot = task._createSnapshot()
    json = subject.serialize(snapshot)
    assert.equal json.type, 'Foo::BarTask'
    assert.equal undefined, json.qualified_type, 'deletes qualified_type from the payload'

test 'has a custom extractTypeName function to make things easier', (assert) ->
  hashType = subject.extractTypeName('foo', {type: 'bar'})
  assert.equal hashType, 'bar', 'extracts the type from the hash if it exists'

  propType = subject.extractTypeName('cow', {otherStuff: 'whoah'})
  assert.equal propType, 'cow', 'uses the prop for the typeName otherwise'

test "extractSingle puts sideloaded things into the store via their 'type' attribute", (assert) ->
  InitialTechCheckTask = DS.Model.extend
    title: DS.attr('string')
    type: DS.attr('string')

  store = getStore()
  container.register('model:initial-tech-check-task', InitialTechCheckTask)

  jsonHash =
    tasks:
      [ {id: '1', type: 'InitialTechCheckTask', title: 'Initial Tech Check'} ]
    phase:
      id: '1'
      tasks: [{id: '1', type: 'InitialTechCheckTask'}]

  Ember.run ->
    result = subject.extractSingle(store, store.modelFor('phase'), jsonHash)
    assert.equal store.getById('task', 1), null, 'no Task gets pushed into the store'
    store.find('initial-tech-check-task', 1).then (task) ->
      assert.equal task.get('title'), 'Initial Tech Check', 'the message task is in the store'

test "extractMany puts normalizes things via their 'type' attribute", (assert) ->
  PaperEditorTask = DS.Model.extend
    title: DS.attr('string')
    type: DS.attr('string')
    uniqueProperty: DS.attr('string')

  store = getStore()
  container.register('model:paper-editor-task', PaperEditorTask)

  jsonHash =
    users: [{id: '1', username: 'editorGuy'}]
    tasks: [{id: '1', type: 'PaperEditorTask', title: 'Edit Stuff', unique_property: 'foo' }]

  Ember.run ->
    result = subject.extractArray(store, store.modelFor('task'), jsonHash)
    assert.ok result[0].unique_property
