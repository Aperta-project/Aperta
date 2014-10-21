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
