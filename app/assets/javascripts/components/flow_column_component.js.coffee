ETahi.FlowColumnComponent = Ember.Component.extend
  tagName: 'li'
  classNames: ['column']

  editing: false
  editable: false
  emptyText: "There are no matches."

  selectableTaskTypes: (->
    @get('journalTaskTypes').map (type) ->
      id: type.get('kind')
      text: type.get('title')
  ).property()

  selectedTaskType: (->
    console.log(@get('flow.query'))
    if @get('flow.query').type
      type = @get('journalTaskTypes').findBy('kind', @get('flow.query').type)
      id: type.get('kind')
      text: type.get('title')
  ).property()

  actions:
    viewCard: (card) ->
      @sendAction 'viewCard', card

    updateQuery: (query) ->
      @get('flow').set('query', type: query.id)
      @sendAction 'saveFlow', @get('flow')

    save: ->
      @sendAction 'saveFlow', @get('flow')

    cancel: ->
      @get('flow').rollback()
      @send 'toggleEdit'

    toggleEdit: ->
      return unless @get('editable')
      @toggleProperty 'editing'

    removeFlow: ->
      @sendAction 'removeFlow', @get('flow')
