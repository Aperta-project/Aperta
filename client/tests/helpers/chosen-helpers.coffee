`import Ember from 'ember'`

chosenHelpers = (->

  Ember.Test.registerAsyncHelper('pickFromChosenSingle', (app, selector, choice) ->
    click ".chosen-container#{selector} a.chosen-single"
    click "li.active-result:contains('#{choice}')"
  )

)()

`export default chosenHelpers`
