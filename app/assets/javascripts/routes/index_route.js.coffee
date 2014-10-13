ETahi.IndexRoute = Ember.Route.extend
  model: ->
    @store.find 'dashboard'
    .then (dashboardArray) -> dashboardArray.get 'firstObject'

  setupController: (controller, model) ->
    controller.set('model', model)
    papers = @store.filter 'litePaper', (p) ->
      roles = p.get('roles')
      isMyPaper = roles.indexOf('My Paper') > -1
      iAmCollaborator = roles.indexOf('Collaborator') > -1
      isMyPaper || iAmCollaborator

    controller.set('papers', papers)

  actions:
    didTransition: () ->
      @controllerFor('index').set 'pageNumber', 1

    viewCard: (task) ->
      redirectParams = ['index']
      @controllerFor('application').get('overlayRedirect').pushObject(redirectParams)
      @controllerFor('application').set('cachedModel' , @modelFor('index'))
      @controllerFor('application').set('overlayBackground', 'index')
      @transitionTo('task', task.get('litePaper.id'), task.get('id'))

    showNewPaperOverlay: () ->
      @store.find('journal').then (journals) =>
        model = @store.createRecord 'paper',
          journal: journals.get('content.firstObject')
          paperType: journals.get('content.firstObject.paperTypes.firstObject')

        @controllerFor('paperNewOverlay').setProperties
          model: model
          journals: journals

        @render 'paperNewOverlay',
          into: 'application'
          outlet: 'overlay'
          controller: 'paperNewOverlay'

    closeAction: ->
      # not sure why setting journal to null prevents explosions
      # probably ember-data relationship craziness
      @controllerFor('paperNewOverlay').get('model')
                                       .set('journal', null)
                                       .deleteRecord()
      @send('closeOverlay')
