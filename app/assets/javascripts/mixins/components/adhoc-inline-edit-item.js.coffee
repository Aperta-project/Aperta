ETahi.AdhocInlineEditItem = Em.Mixin.create
  editing: Em.computed.alias('parentView.editing')
  isNew: false
  bodyPart: null
  bodyPartType: Ember.computed.alias 'bodyPart.type'

  actions:
    deleteItem: ->
      @sendAction('delete', @get('bodyPart'))
