ETahi.AdhocInlineEditItem = Em.Mixin.create
  editing: Em.computed.alias('parentView.editing')
  isNew: false
  bodyPart: null

  actions:
    deleteItem: ->
      @sendAction('delete', @get('bodyPart'))
