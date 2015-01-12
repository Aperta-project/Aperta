`import Ember from 'ember'`

ManuscriptManagerTemplateRoute = Ember.Route.extend
  actions:
    chooseNewCardTypeOverlay: (phaseTemplate) ->
      journalTaskTypes = @modelFor('admin.journal').get('journalTaskTypes')
      @controllerFor('overlays/chooseNewCardType').setProperties(phaseTemplate: phaseTemplate, journalTaskTypes: journalTaskTypes)
      @render('overlays/add-manuscript-template-card',
        into: 'application'
        outlet: 'overlay'
        controller: 'overlays/chooseNewCardType')

    addTaskType: (phaseTemplate, taskType) ->
      newTask = @store.createRecord('taskTemplate',
        title: taskType.get('title')
        journalTaskType: taskType
        phaseTemplate: phaseTemplate
        template: [])

      if taskType.get('kind') == "Task"
        @controllerFor('overlays/adHocTemplate').setProperties(phaseTemplate: phaseTemplate, model: newTask, isNewTask: true)
        @render('overlays/adHocTemplate',
          into: 'application'
          outlet: 'overlay'
          controller: 'overlays/adHocTemplate')
      else
        @send('addTaskAndClose')

    addTaskAndClose: ->
      @controllerFor('admin.journal.manuscriptManagerTemplate/edit').set('dirty', true)
      @send('closeOverlay')

    closeAction: ->
      @send('closeOverlay')

    viewCard: -> #no-op

    showDeleteConfirm: (task) ->
      @controllerFor('overlays/cardDelete').set('task', task)
      @render('cardDeleteOverlay',
        into: 'application'
        outlet: 'overlay'
        controller: 'overlays/cardDelete')

`export default ManuscriptManagerTemplateRoute`

