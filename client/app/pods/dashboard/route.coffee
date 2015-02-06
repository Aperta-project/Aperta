`import Ember from 'ember'`

DashboardRoute = Ember.Route.extend
  model: ->
    @store.find('dashboard').then (dashboardArray) ->
      dashboardArray.get 'firstObject'

  setupController: (controller, model) ->
    @store.find('commentLook') # don't wait to fulfill
    controller.set('model', model)
    papers = @store.filter 'litePaper', (p) ->
      !Ember.isEmpty p.get('roles')

    controller.set('papers', papers)
    controller.set('unreadComments', @store.all('commentLook'))

  actions:
    didTransition: () ->
      @controllerFor('dashboard').set 'pageNumber', 1
      return true

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
          editable: true
          body: ''

        @controllerFor('overlays/paperNew').setProperties
          model: model
          journals: journals

        @render 'overlays/paperNew',
          into: 'application'
          outlet: 'overlay'
          controller: 'overlays/paperNew'

    closeAction: ->
      # not sure why setting journal to null prevents explosions
      # probably ember-data relationship craziness
      @controllerFor('overlays/paperNew').get('model')
        .set('journal', null)
        .deleteRecord()
      @send('closeOverlay')

`export default DashboardRoute`
