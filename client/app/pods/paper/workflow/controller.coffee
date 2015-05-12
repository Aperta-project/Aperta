`import Ember from 'ember';`
`import RESTless from 'tahi/services/rest-less';`

Controller = Ember.Controller.extend
  positionSort: ["position:asc"]
  sortedPhases: Ember.computed.sort('model.phases', 'positionSort')

  commentLooks: Em.computed -> @store.all('commentLook')

  allTaskIds: ->
    @store.all('phase').reduce((taskIds, phase) ->
      taskIds.concat phase.get('tasks').map (task) -> task.get('id')
    , [])

  allTaskIdsSnapshot: (->
    @allTaskIds()
  ).on('init').property()

  updatePositions: (phase) ->
    relevantPhases = @get('model.phases').filter((p)->
      p != phase && p.get('position') >= phase.get('position')
    )

    relevantPhases.invoke('incrementProperty', 'position')

  paper: Ember.computed.alias('model')
  canRemoveCard: true

  actions:
    changePhaseForTask: (task, targetPhaseId) ->
      @beginPropertyChanges()
      @store.getById('phase', targetPhaseId)
            .get('tasks').addObject(task)
      @endPropertyChanges()

    addPhase: (position) ->
      paper = @get('model')
      phase = @store.createRecord 'phase',
        position: position
        name: "New Phase"
        paper: paper
      @updatePositions(phase)
      phase.save().then ->
        paper.reload()

    changeTaskPhase: (task, targetPhase) ->
      task.set('phase', targetPhase)

    removePhase: (phase) ->
      paper = phase.get('paper')
      phase.destroyRecord().then ->
        paper.reload()

    savePhase: (phase) ->
      phase.save()

    rollbackPhase: (phase) ->
      phase.rollback()

    toggleEditable: ->
      RESTless.putUpdate(@get('model'), '/toggle_editable').catch ({status, model}) =>
        message = switch status
          when 422 then model.get('errors.messages') + " You should probably reload."
          when 403 then "You weren't authorized to do that"
          else "There was a problem saving.  Please reload."
        @flash.displayMessage 'error', message

`export default Controller;`
