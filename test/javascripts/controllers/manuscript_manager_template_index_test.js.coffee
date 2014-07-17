moduleFor 'controller:manuscriptManagerTemplateIndex', 'ManuscriptManagerTemplateIndexController',
  tearDown: -> ETahi.reset()
  setup: ->
    setupApp()
    @phase = ETahi.TemplatePhase.create name: 'First Phase'
    task1 = ETahi.TemplateTask.create title: 'ATask', phase: @phase
    task2 = ETahi.TemplateTask.create title: 'BTask', phase: @phase
    @phase.set('task_types', [task1, task2])
    template =
      name: 'A name'
      id: 1
      journal_id: 5
      paper_type: 'A type'
      template:
        phases: [@phase]

    Ember.run =>
      @template = ETahi.ManuscriptManagerTemplate.create(template)
      @ctrl = @subject()
      @ctrl.set 'model', [@template]

test '#destroyTemplate does not delete the last template', ->
  @ctrl.send 'destroyTemplate', @template
  equal(@ctrl.get('model.length'), 1)

test '#destroyTemplate deletes the given template when there are more than one templates', ->
  handler = () ->

  nextTemplate =
    name: 'Next name'
    id: 2
    journal_id: 5
    paper_type: 'Next type'
    template:
      phases: [@phase]

  Ember.run =>
    @nextTemplate = ETahi.ManuscriptManagerTemplate.create(nextTemplate)
    @ctrl.set 'model', [@template, @nextTemplate]
    sinon.stub(@nextTemplate, 'destroyRecord').returns(new Ember.RSVP.Promise(handler, handler))
    @ctrl.send 'destroyTemplate', @nextTemplate
    ok @nextTemplate.destroyRecord.called
