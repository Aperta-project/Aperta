ETahi.ManuscriptManagerTemplateEditController = Ember.ObjectController.extend

  paperTypes: (->
    @get('journal.paperTypes')
  ).property('journal.paperTypes.@each')

  sortedPhases: Ember.computed.alias 'template.phases'

  updatePositions: (phase) ->
    # relevantPhases = @get('model.phases').filter((p)->
    #   p != phase && p.get('position') >= phase.get('position')
    # )

    # relevantPhases.invoke('incrementProperty', 'position')


  actions:
    changeTaskPhase: (task, targetPhase) ->

    addPhase: (position) ->
      newPhase = Ember.Object.create name: 'New Phase', tasks: [], position: position
      @get('template.phases').insertAt(position - 1, newPhase)

    removePhase: (phase) ->

    removeTask: (task) ->

    savePhase: (phase) ->

    rollbackPhase: (phase, oldName) ->
      phase.set('name', oldName)

