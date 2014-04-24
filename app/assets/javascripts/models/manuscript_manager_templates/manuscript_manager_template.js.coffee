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
    @updateSnapshot()

  articleCount: 0

  phaseCount: Ember.computed.alias 'phases.length'

  isNew: Em.computed.empty('id')

  templateJSON: ( ->
    serializedPhases = @get('phases').map (phase) ->
      task_types = phase.get('tasks').map (task) ->
        task.get('type')
      phase =
        name: phase.get('name')
        task_types: task_types

    id: @get('id')
    paper_type: @get('paperType')
    name: @get('name')
    template:
      phases: serializedPhases
  ).property().volatile()

  savePayload: ( ->
    payload = { journal_id: @get('journalId'), manuscript_manager_template: @get('templateJSON') }
    id = @get('id')
    if @get('isNew')
      url = "/manuscript_manager_templates/"
      type = "POST"
    else
      url = "/manuscript_manager_templates/#{id}"
      type = "PUT"

    url: url
    type: type
    data: JSON.stringify(payload)
    contentType: 'application/json; charset=utf-8'
  ).property().volatile()

  deletePayload: ( ->
    payload = { journal_id: @get('journalId'), "_method": "delete" }

    url: "/manuscript_manager_templates/#{@get('id')}"
    type: "DELETE"
    data: JSON.stringify(payload)
    contentType: 'application/json; charset=utf-8'
  ).property().volatile()

  save: ->
    @updateSnapshot()
    new Ember.RSVP.Promise (resolve, reject) =>
      $.ajax(@get('savePayload')).then(resolve).fail(reject)

  destroyRecord: ->
    new Ember.RSVP.Promise (resolve, reject) =>
      if @get('isNew')
        resolve()
      else
        $.ajax(@get('deletePayload')).then(resolve).fail(reject)

  rollback: ->
    snapshot = @get('snapshot')
    @setProperties
      name: snapshot.name
      paperType: snapshot.paperType
      phases: snapshot.phases.copy(true)

  updateSnapshot: ->
    @set 'snapshot',
      name: @get('name')
      paperType: @get('paperType')
      phases: @get('phases').copy(true)
