`import Ember from 'ember'`

storeHelpers = (->

  Ember.Test.registerHelper('pushModel', (app, type, data) ->
    store = app.__container__.lookup('store:main')
    Ember.run ->
      store.push(type, data)
      store.getById(type, data.id)
  )

  Ember.Test.registerHelper('pushPayload', (app, type, data) ->
    store = app.__container__.lookup('store:main')
    Ember.run ->
      store.pushPayload(type, data)
  )

  Ember.Test.registerHelper('getStore', (app) ->
    app.__container__.lookup('store:main')
  )

  Ember.Test.registerHelper('getCurrentUser', (app) ->
    app.__container__.lookup('user:current')
  )

)()

`export default storeHelpers`
