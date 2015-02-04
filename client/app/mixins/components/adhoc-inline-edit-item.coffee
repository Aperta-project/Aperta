`import Ember from 'ember'`

AdhocInlineEditItem = Ember.Mixin.create
  editing: Ember.computed.alias('parentView.editing')
  isNew: false
  bodyPart: null
  bodyPartType: Ember.computed.alias 'bodyPart.type'

  actions:
    deleteItem: ->
      @sendAction('delete', @get('bodyPart'))

`export default AdhocInlineEditItem`
