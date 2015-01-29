`import Ember from 'ember'`
`import RESTless from 'tahi/services/rest-less'`

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
        supportedExportFormats = []
        for dataType in data.export_formats
          supportedExportFormats.pushObject({format: dataType, icon: "svg/#{dataType}-icon"})
        controller.set('supportedDownloadFormats', supportedExportFormats)

    Ember.$.getJSON('/formats', setFormats)

  serialize: (model, params) ->
    if doi = model.get('doi')
      paper_id: doi
    else
      @_super(model, params)

`export default PaperRoute`
