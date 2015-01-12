`import Ember from 'ember'`
`import AdhocInlineEditItem from 'tahi/mixins/components/adhoc-inline-edit-item'`

InlineEditCheckboxComponent = Ember.Component.extend AdhocInlineEditItem,
  checked: ((key, value, oldValue) ->
    if arguments.length > 1
      #setter
      @set('bodyPart.answer', value)
    else
      #getter
      answer = @get('bodyPart.answer')
      answer == 'true' || answer == true
  ).property('bodyPart.answer')

  actions:
    saveModel: ->
      @sendAction('saveModel')

    deleteItem: ->
      @sendAction('delete', @get('bodyPart'), @get('parentView.block'))

`export default InlineEditCheckboxComponent`
