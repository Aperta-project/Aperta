env = {}
setupStore = ->
  env.serializer = ETahi.__container__.lookup "serializer:application"
  env.store = ETahi.__container__.lookup "store:main"

module 'integration/serializer',

teardown: -> ETahi.reset()
setup: ->
  setupApp(integration: true)
  setupStore(env)

test 'normalizeType denamespaces task types', ->
  result = env.serializer.normalizeType({type: 'Foo::BarTask'})
  equal result.qualified_type, 'Foo::BarTask', 'saves the original type as qualified_type'
  equal result.type, 'BarTask', 'strips the namespace off the type'

test 'Combines the namespace with task if the name of the type is ::Task', ->
  result = env.serializer.normalizeType({type: 'Foo::Task'})
  equal result.type, 'FooTask', 'uses the namespace + the task for the name'

test 'serializing a model that was originally namespaced will correctly re-namespace it', ->
  Ember.run ->
    task = env.store.createRecord('task', qualifiedType: "Foo::BarTask")
    json = env.serializer.serialize(task)
    equal json.type, "Foo::BarTask"
    equal undefined, json.qualified_type, 'deletes qualified_type from the payload'

test 'has a custom extractTypeName function to make things easier', ->
  hashType = env.serializer.extractTypeName('foo', {type: 'bar'})
  equal hashType, 'bar', 'extracts the type from the hash if it exists'

  propType = env.serializer.extractTypeName('cow', {otherStuff: 'whoah'})
  equal propType, 'cow', 'uses the prop for the typeName otherwise'

test "extractSingle puts sideloaded things into the store via their 'type' attribute", ->
  jsonHash =
    tasks:
      [ {id: '1', type: 'MessageTask', title: 'A Message'}
        {id: '2', type: 'Foo::PlosAuthorsTask', title: 'Check Authors'}
      ]

     phase:
       id: '1'
       tasks: [{id: '1', type: 'MessageTask'}, {id: '2', type: 'PlosAuthorsTask'}]
  # make sure the store is set up for the model, otherwise the typeKey
  # won't be properly set for some reason and primaryTypeName will be
  # undefined
  env.store.modelFor('task')
  env.store.modelFor('phase')
  Ember.run ->
    result = env.serializer.extractSingle(env.store, ETahi.Phase, jsonHash)
    equal env.store.getById('task', 1), null, 'no Task gets pushed into the store'
    env.store.find('messageTask', 1).then (task) ->
      equal task.get('title'), 'A Message', 'the message task is in the store'
    env.store.find('plosAuthorsTask', 2).then (task) ->
      equal task.get('title'), 'Check Authors', 'the namespaced authors task is in the store'

test "extractMany puts normalizes things via their 'type' attribute", ->
  jsonHash =
    users: [{id: '1', username: 'editorGuy'}]
    tasks:
      [ {id: '1', type: 'PaperEditorTask', title: 'Edit Stuff', editor_id: '1'} ]
  # make sure the store is set up for the model, otherwise the typeKey
  # won't be properly set for some reason and primaryTypeName will be
  # undefined
  env.store.modelFor('task')
  Ember.run ->
    result = env.serializer.extractArray(env.store, ETahi.Task, jsonHash)
    ok result[0].editor
    # TODO: test that the various tasks are normalized properly.  PaperEditorTask, etc.
