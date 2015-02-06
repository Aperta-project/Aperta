`import Ember from 'ember'`

customAssertions = (->

  Ember.Test.registerHelper('assertText', (app, selector, text) ->
    ok Em.$.trim(find(selector).text()).indexOf(text) isnt -1, "it should have text: #{text} within #{selector}"
  )

  Ember.Test.registerHelper('assertNoText', (app, selector, text) ->
    ok Em.$.trim(find(selector).text()).indexOf(text) is -1, "it should not have text: #{text} within #{selector}"
  )

)()

`export default customAssertions`
