ETahi.PaperRoute = Ember.Route.extend
  model: (params) ->
    [publisher_prefix, suffix] = params.paper_id.toString().split('/')
    if publisher_prefix && suffix
      doi = "#{publisher_prefix}/#{suffix}"
      ETahi.RESTless.get("/papers/#{doi}").then (data) =>
        @store.pushPayload('paper', data)
        @store.all('paper').find (paper) => paper.get('doi') == doi
    else
      @store.find('paper', params.paper_id)

  setupController: (controller, model) ->
    controller.set('model', model)
    if controller.get('supportedDownloadFormats') then return
    setFormats = (data) ->
      if !data then return # IHAT_URL is not set in rails.
      Ember.run ->
        window.ETahi.supportedDownloadFormats = window.ETahi.supportedDownloadFormats || data
        exportFormats = data.export_formats
        for dataType in exportFormats
          dataType.icon = "svg/#{dataType.format}-icon"
        controller.set('supportedDownloadFormats', exportFormats)

    if window.ETahi.supportedDownloadFormats
      return setFormats(window.ETahi.supportedDownloadFormats)

    Em.$.getJSON('/formats', setFormats)

  serialize: (model, params) ->
    if doi = model.get('doi')
      paper_id: doi
    else
      @_super(model, params)
