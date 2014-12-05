ETahi.PaperRoute = Ember.Route.extend
  model: (params) ->
    if params.paper_id
      @store.find('paper', params.paper_id)
    else if params.publisher_prefix && params.suffix
      doi = params.publisher_prefix + '/' + params.suffix
      @store.find('paper', doi)

  afterModel: (paper, transition) ->
    if paper.id
      doi = paper.get("doi")
      if doi
        @transitionTo "paper.edit", doi

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
