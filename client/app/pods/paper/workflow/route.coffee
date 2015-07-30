`import Ember from 'ember'`
`import AuthorizedRoute from 'tahi/routes/authorized'`
`import Utils from 'tahi/services/utils'`

PaperManageRoute = AuthorizedRoute.extend
  cardOverlayService: Ember.inject.service('card-overlay'),

  afterModel: (paper, transition) ->
    # TODO: No no. We should be able to remove or move this check to somewhere
    # that doesn't block rendering. We only do this now because all tasks are
    # loaded for all users. This will be changing in the future.

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
      @get('cardOverlayService').setProperties({
        previousRouteOptions: ['paper.workflow', @modelFor('paper')]
        overlayBackground: 'paper/workflow'
      })

      queryParams || = {queryParams: {}}
      @transitionTo('paper.task', @modelFor('paper'), task.id, queryParams)

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
