ETahi.PaperManageRoute = ETahi.AuthorizedRoute.extend
  afterModel: (paper, transition) ->
    # Ping manuscript_manager url for authorization
    promise = new Ember.RSVP.Promise (resolve, reject) ->
      Ember.$.ajax
        method:  'GET'
        url:     "/papers/#{paper.get('id')}/manuscript_manager"
        success: (json) -> Ember.run(null, resolve, json)
        error:   (xhr, status, error) -> Ember.run(null, reject, xhr)

  setupController: (controller, model) ->
    controller.set('model', model)
    controller.set('commentLooks', @store.all('commentLook'))
    controller.set('canRemoveCard', true)

  actions:
    chooseNewCardTypeOverlay: (phase) ->
      @controllerFor('chooseNewCardTypeOverlay').set('phase', phase)

      @store.find('adminJournal', phase.get('paper.journal.id')).then (adminJournal) =>
        @controllerFor('chooseNewCardTypeOverlay').set('journalTaskTypes', adminJournal.get('journalTaskTypes'))

      @render('chooseNewCardTypeOverlay',
        into: 'application'
        outlet: 'overlay'
        controller: 'chooseNewCardTypeOverlay')

    viewCard: (task, queryParams) ->
      queryParams || = {queryParams: {}}
      paper = @modelFor('paper')
      redirectParams = ['paper.manage', @modelFor('paper')]
      @controllerFor('application').get('overlayRedirect').pushObject(redirectParams)
      @controllerFor('application').set('overlayBackground', 'paper/manage')
      @transitionTo('task', paper.id, task.id, queryParams)

    addTaskType: (phase, taskType) ->
      return unless taskType
      unNamespacedKind = Tahi.utils.deNamespaceTaskType taskType.get('kind')

      @store.createRecord(unNamespacedKind,
        phase: phase
        role: taskType.get 'role'
        type: taskType.get 'kind'
        paper: @modelFor 'paper'
        title: taskType.get 'title'
      ).save().then (newTask) =>
        @send 'viewCard', newTask, {queryParams: {isNewTask: true}}
