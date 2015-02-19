`import Ember from 'ember'`
`import RESTless from 'tahi/services/rest-less'`
`import Utils from 'tahi/services/utils'`

PaperRoute = Ember.Route.extend
  model: (params) ->
    [publisher_prefix, suffix] = params.paper_id.toString().split('/')
    if publisher_prefix && suffix
      doi = "#{publisher_prefix}/#{suffix}"
      RESTless.get("/papers/#{doi}").then (data) =>
        @store.pushPayload('paper', data)
        @store.all('paper').find (paper) -> paper.get('doi') == doi
    else
      @store.find('paper', params.paper_id)

  setupController: (controller, model) ->
    controller.set('model', model)

    setFormats = (data) ->
      if !data then return # IHAT_URL is not set in rails.
      Ember.run ->
        exportFormats = data.export_formats
        for dataType in exportFormats
          dataType.icon = "svg/#{dataType.format}-icon"
        controller.set('supportedDownloadFormats', exportFormats)

    Ember.$.getJSON('/formats', setFormats)

  serialize: (model, params) ->
    if doi = model.get('doi')
      paper_id: doi
    else
      @_super(model, params)

  actions:
    showActivityFeed: (name) ->
      paper = @modelFor('paper')
      controller = @controllerFor 'overlays/activityFeed'
      controller.set 'isLoading', true

      RESTless.get("/papers/#{paper.get('id')}/activity_feed/#{name}").then (data) =>
        controller.setProperties
          isLoading: false
          model: Utils.deepCamelizeKeys(data.feeds)

      @render 'overlays/activityFeed',
        into: 'application',
        outlet: 'overlay',
        controller: controller

`export default PaperRoute`
