#= require test_helper

moduleFor 'route:manuscriptManagerTemplate', 'Unit: route/ManuscriptManagerTemplateRoute',
  setup: ->
    phase = name: 'First Phase', task_types: ['ATask', 'AnotherTask']
    template =
      name: 'A name'
      paper_type: 'A type'
      template:
        phases: [phase]
    data = {manuscript_manager_templates: [template]}
    Ember.run =>
      result = @subject().normalizeTemplateModels(data).get('firstObject')
      @phases = result.get('template.phases')

test '#normalizeTemplateModels creates phase objects for the phases in a template', ->
  equal @phases.length, 1
  equal @phases.get('firstObject.name'), 'First Phase'

test '#normalizeTemplateModels assigns a position to the created phase object', ->
  equal @phases.get('firstObject.position'), 1

test '#normalizeTemplateModels creates task objects for the task types in a phase', ->
  tasks = @phases.get('firstObject.tasks')
  equal tasks.get('length'), 2
  equal tasks.get('firstObject.title'), 'ATask'

