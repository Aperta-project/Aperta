`import Ember from 'ember'`

chosenHelpers = (->

  Ember.Test.registerAsyncHelper('pickFromChosenSingle', (app, selector, choice) ->
    click ".chosen-container#{selector} a.chosen-single"
    click "li.active-result:contains('#{choice}')"
  )

  Ember.Test.registerAsyncHelper('pickFromSelect2', (app, scope, choice) ->
    keyEvent("#{scope} .select2-container input", 'keydown')
    fillIn("#{scope} .select2-container input", choice)
    keyEvent("#{scope} .select2-container input", 'keyup')
    waitForElement('.select2-result-selectable')
    click(".select2-result-selectable", 'body')
  )

)()

`export default chosenHelpers`
