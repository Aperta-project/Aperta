`import Ember from 'ember'`

select2Helpers = (->

  Ember.Test.registerAsyncHelper('pickFromSelect2', (app, scope, choice) ->
    keyEvent("#{scope} .select2-container input", 'keydown')
    fillIn("#{scope} .select2-container input", choice)
    keyEvent("#{scope} .select2-container input", 'keyup')
    waitForElement('.select2-result-selectable')
    click(".select2-result-selectable", 'body')
  )

)()

`export default select2Helpers`
