ETahi.ManuscriptManagerTemplate = Ember.Object.extend
  init: ->
    normalizedPhases = @get('template').phases.map (phase) ->
      newPhase = ETahi.TemplatePhase.create(name: phase.name)
      tasks = phase.task_types.map (task) ->
        ETahi.TemplateTask.create(type: task, phase: newPhase)
      newPhase.set('tasks', tasks)
      newPhase
    @setProperties
      journalId: @get('journal_id')
      paperType: @get('paper_type')
      phases: normalizedPhases
      template: null

  articleCount: 0

  phaseCount: Ember.computed.alias 'phases.length'

  templateJSON: ( ->
    serializedPhases = @get('phases').map (phase) ->
      task_types = phase.get('tasks').map (task) ->
        task.get('type')
      phase =
        name: phase.get('name')
        task_types: task_types

    payload =
      id: @get('id')
      paper_type: @get('paperType')
      name: @get('name')
      template:
        phases: serializedPhases
  ).property().volatile()

  ajaxPayload: ( ->
    payload = { journal_id: @get('journalId'), manuscript_manager_template: @get('templateJSON') }
    id = @get('id')
    if id
      url = "/manuscript_manager_templates/#{id}"
      type = "PUT"
    else
      url = "/manuscript_manager_templates/"
      type = "POST"

    url: url
    type: type
    data: JSON.stringify(payload)
    contentType: 'application/json; charset=utf-8'
  ).property().volatile()

  save: ->
    saveTemplate = new Ember.RSVP.Promise (resolve, reject) =>
      $.ajax(@get('ajaxPayload')).then(resolve).fail(reject)
