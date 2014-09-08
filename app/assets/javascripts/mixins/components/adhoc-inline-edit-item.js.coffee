ETahi.AdhocInlineEditItem = Em.Mixin.create
  editing: Em.computed.alias('parentView.editing')
  isNew: false

  actions:
    deleteItem: ->
      @sendAction('delete', @get('bodyPart'))
