ETahi.FlowColumnComponent = Ember.Component.extend
  tagName: 'li'
  classNames: ['column']

  editing: false
  editable: false
  emptyText: "There are no matches."

  actions:
    viewCard: (card) ->
      @sendAction 'viewCard', card

    save: ->
      @get('flow').set('query', @get('query'))
      @sendAction 'saveFlow', @get('flow')

    cancel: ->
      @get('flow').rollback()
      @send 'toggleEdit'

    toggleEdit: ->
      return unless @get('editable')
      @toggleProperty 'editing'

    removeFlow: ->
      @sendAction 'removeFlow', @get('flow')
