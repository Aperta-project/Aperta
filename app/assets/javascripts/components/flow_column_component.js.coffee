possibleFlowNames = [
  { id: 0, text: 'Up for grabs' },
  { id: 1, text: 'My tasks' },
  { id: 2, text: 'My papers' },
  { id: 3, text: 'Done' }]

ETahi.FlowColumnComponent = Ember.Component.extend
  tagName: 'li'
  classNames: ['column']

  editing: false
  editable: false
  emptyText: "There are no matches."

  formattedFlowTitle: Em.computed 'flow.title', ->
    possibleFlowNames.findBy('text', @get('userFlow.title'))

  possibleFlowNames: possibleFlowNames

  actions:
    viewCard: (card) ->
      @sendAction 'viewCard', card

    save: ->
      @sendAction 'saveFlow', @get('userFlow')

    cancel: ->
      @get('flow').rollback()
      @send 'toggleEdit'

    toggleEdit: ->
      return unless @get('editable')
      @toggleProperty 'editing'

    removeFlow: ->
      @sendAction 'removeFlow', @get('userFlow')
