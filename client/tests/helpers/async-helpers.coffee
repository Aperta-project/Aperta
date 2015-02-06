`import Ember from 'ember'`

asyncHelpers = (->

  Ember.Test.registerAsyncHelper "waitForElement", (app, element) ->
    Ember.Test.promise (resolve) ->
      Ember.Test.adapter.asyncStart()
      interval = setInterval(->
        if $(element).length > 0
          clearInterval interval
          Ember.Test.adapter.asyncEnd()
          Ember.run null, resolve, true
        return
      , 10)
      return
)()

`export default asyncHelpers`
