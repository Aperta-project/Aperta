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

    createAdhocTask: (phase) ->
      paper = @controllerFor('paperManage').get('model')
      newTask = @store.createRecord 'task',
        phase: phase
        type: 'Task'
        paper: paper
        title: 'New Ad-Hoc Card'

      newTask.save().then =>
        @send('viewCard', newTask, {queryParams: {isNewTask: true}})

      false
