`import Ember from 'ember'`

containerHelpers = (->

  Ember.Test.registerHelper('getContainer', (app) ->
    app.__container__
  )
)()

`export default containerHelpers`
