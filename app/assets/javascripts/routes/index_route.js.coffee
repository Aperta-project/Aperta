ETahi.IndexRoute = Ember.Route.extend
  model: ->
    @store.find 'dashboard'
    .then (dashboardArray) -> dashboardArray.get 'firstObject'

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
      @controllerFor('paperNewOverlay').get('model').destroyRecord()
      @send('closeOverlay')
