`import Ember from 'ember'`
`import RESTless from 'tahi/services/rest-less'`
`import Utils from 'tahi/services/utils'`

PaperRoute = Ember.Route.extend
  model: (params) ->
    @store.fetchById('paper', params.paper_id)

  setupController: (controller, model) ->
    controller.set('model', model)

    setFormats = (data) ->
      if !data then return # IHAT_URL is not set in rails.
      Ember.run ->
        supportedExportFormats = []
        for dataType in data.export_formats
          supportedExportFormats.pushObject({format: dataType, icon: "svg/#{dataType}-icon"})
        controller.set('supportedDownloadFormats', supportedExportFormats)

    Ember.$.getJSON('/api/formats', setFormats)

  actions:
    addContributors: ->
      paper = @modelFor('paper')
      collaborations = paper.get('collaborations') || []
      controller = @controllerFor('overlays/showCollaborators')
      controller.setProperties
        paper: paper
        collaborations: collaborations
        initialCollaborations: collaborations.slice()
        allUsers: @store.find('user')

      @render('overlays/showCollaborators',
        into: 'application'
        outlet: 'overlay'
        controller: controller)

    showActivityFeed: (name) ->
      paper = @modelFor('paper')
      controller = @controllerFor 'overlays/activityFeed'
      controller.set 'isLoading', true

      RESTless.get("/api/papers/#{paper.get('id')}/activity_feed/#{name}").then (data) =>
        controller.setProperties
          isLoading: false
          model: Utils.deepCamelizeKeys(data.feeds)

      @render 'overlays/activityFeed',
        into: 'application',
        outlet: 'overlay',
        controller: controller

`export default PaperRoute`
