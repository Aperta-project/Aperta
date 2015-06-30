`import Ember from 'ember'`
`import AuthorizedRoute from 'tahi/routes/authorized'`
`import Utils from 'tahi/services/utils'`

PaperManageRoute = AuthorizedRoute.extend
  afterModel: (paper, transition) ->
    # Ping manuscript_manager url for authorization
    promise = new Ember.RSVP.Promise (resolve, reject) ->
      Ember.$.ajax
        method:  'GET'
        url:     "/api/papers/#{paper.get('id')}/manuscript_manager"
        success: (json) -> Ember.run(null, resolve, json)
        error:   (xhr, status, error) -> Ember.run(null, reject, xhr)

  actions:
    chooseNewCardTypeOverlay: (phase) ->
      chooseNewCardTypeOverlay = @controllerFor('overlays/chooseNewCardType')
      chooseNewCardTypeOverlay.set('phase', phase)

      @store.find('adminJournal', phase.get('paper.journal.id')).then (adminJournal) =>
        chooseNewCardTypeOverlay.set('journalTaskTypes', adminJournal.get('journalTaskTypes'))

      @send('openOverlay', {
        template: 'overlays/chooseNewCardType'
        controller: chooseNewCardTypeOverlay
      })

    viewCard: (task, queryParams) ->
      queryParams || = {queryParams: {}}
      paper = @modelFor('paper')
      redirectParams = ['paper.workflow', @modelFor('paper')]
      @controllerFor('application').get('overlayRedirect').pushObject(redirectParams)
      @controllerFor('application').set('overlayBackground', 'paper/workflow')
      @transitionTo('paper.task', paper, task.id, queryParams)

    addTaskType: (phase, taskType) ->
      return unless taskType
      unNamespacedKind = Utils.deNamespaceTaskType taskType.get('kind')

      @store.createRecord(unNamespacedKind,
        phase: phase
        role: taskType.get 'role'
        type: taskType.get 'kind'
        paper: @modelFor 'paper'
        title: taskType.get 'title'
      ).save().then (newTask) =>
        @send 'viewCard', newTask, {queryParams: {isNewTask: true}}

    showDeleteConfirm: (task) ->
      @send('openOverlay', {
        template: 'overlays/card-delete'
        controller: 'overlays/card-delete'
        model: task
      })

`export default PaperManageRoute`
