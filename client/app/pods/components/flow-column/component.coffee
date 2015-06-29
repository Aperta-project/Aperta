`import Ember from 'ember'`
`import Utils from 'tahi/services/utils'`

FlowColumnComponent = Ember.Component.extend
  tagName: 'li'
  classNames: ['column']

  editing: false
  editable: false
  emptyText: 'There are no matches.'

  sortBy: 'asc'

  tasksSortBy: (->
    ["createdAt:#{@get('sortBy')}"]
  ).property('sortBy')

  tasks: Ember.computed.sort('flow.tasks', 'tasksSortBy')

  flowTitleDidChange: (->
    Ember.run.schedule('afterRender', this, Utils.resizeColumnHeaders)
  ).observes('flow.title', 'editing')

  # data for select2-compliant queries

  selectableTaskTypes: Ember.computed ->
    @selectableQueries(@get('journalTaskTypes'), 'kind', 'title')

  selectedTaskType: Ember.computed ->
    @selectedQuery(@get('selectableTaskTypes').findBy('id', @get('flow.query').type))

  selectableTaskStates: Ember.computed ->
    [{ id: "completed", text: "Completed" }, { id: "incomplete", text: "Incomplete" }]

  selectedTaskState: Ember.computed ->
    @selectedQuery(@get('selectableTaskStates').findBy('id', @get('flow.query').state))

  selectableTaskAssignments: Ember.computed ->
    [{ id: "true", text: "Me" }, { id: "false", text: "None" }]

  selectedTaskAssignment: Ember.computed ->
    @selectedQuery(@get('selectableTaskAssignments').findBy('id', @get('flow.query').assigned))

  selectableTaskRoles: Ember.computed ->
    @get('flow.taskRoles').map (role) ->
      id: role
      text: role.capitalize()

  selectedTaskRole: Ember.computed ->
    @selectedQuery(@get('selectableTaskRoles').findBy('id', @get('flow.query').role))

  selectableQueries: (options, idKey, textKey) ->
    options.map (option) ->
      id: option.get(idKey)
      text: option.get(textKey)

  selectedQuery: (option) ->
    if option
      id: option.id
      text: option.text

  actions:
    viewCard: (card) ->
      @sendAction 'viewCard', card

    updateTypeQuery: (query) ->
      @get('flow.query').type = query.id
      @send 'save'

    updateStateQuery: (query) ->
      @get('flow.query').state = query.id
      @send 'save'

    updateAssignmentQuery: (query) ->
      @get('flow.query').assigned = query.id
      @send 'save'

    updateRoleQuery: (query) ->
      @get('flow.query').role = query.id
      @send 'save'

    removeTypeQuery: ->
      delete @get('flow.query').type
      @send 'save'

    removeStateQuery: ->
      delete @get('flow.query').state
      @send 'save'

    removeAssignmentQuery: ->
      delete @get('flow.query').assigned
      @send 'save'

    removeRoleQuery: ->
      delete @get('flow.query').role
      @send 'save'

    save: ->
      @sendAction 'saveFlow', @get('flow')
      @send 'toggleEdit'
      Ember.run.schedule('afterRender', this, Utils.resizeColumnHeaders)

    cancel: ->
      @get('flow').rollbackAttributes()
      @send 'toggleEdit'
      Ember.run.schedule('afterRender', this, Utils.resizeColumnHeaders)

    toggleEdit: ->
      return unless @get('editable')
      @toggleProperty 'editing'

    removeFlow: ->
      @sendAction 'removeFlow', @get('flow')

    setSortOrder: (value)->
      @set 'sortBy', value

`export default FlowColumnComponent`
