ETahi.ManuscriptManagerTemplateEditController = Ember.ObjectController.extend

  paperTypes: (->
    @get('journal.paperTypes')
  ).property('journal.paperTypes.@each')

  sortedPhases: Ember.computed.alias 'phases'

  actions:
    changeTaskPhase: (task, targetPhase) ->
      task.get('phase').removeTask(task)
      targetPhase.addTask(task)

    addPhase: (position) ->
      newPhase = ETahi.TemplatePhase.create name: 'New Phase'
      @get('phases').insertAt(position, newPhase)

    removePhase: (phase) ->
      phaseArray = @get('phases')
      phaseArray.removeAt(phaseArray.indexOf(phase))

    addTask: (phase, taskName) ->
      newTask = ETahi.TemplateTask.create type: taskName
      phase.addTask(newTask)

    removeTask: (task) ->
      task.destroy()

    savePhase: (phase) ->

    rollbackPhase: (phase, oldName) ->
      phase.set('name', oldName)

    saveTemplate: ->
      template = @get('model')
      payload = { journal_id: @get('journal.id'), manuscript_manager_template: template.get('templateJSON') }
      saveTemplate = new Ember.RSVP.Promise (resolve, reject) =>
        $.ajax
          url: "/manuscript_manager_templates/#{template.get('id')}"
          type: "PUT"
          data: JSON.stringify(payload)
          success: resolve
          error: reject
          contentType: 'application/json; charset=utf-8'
