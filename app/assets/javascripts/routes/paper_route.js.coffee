ETahi.PaperRoute = Ember.Route.extend
  model: (params) ->
    @store.find('paper', params.paper_id)

  setupController: (controller, model) ->
    controller.set('model', model)
    if controller.get('supportedDownloadFormats') then return
    setFormats = (data) ->
      Ember.run ->
        window.ETahi.supportedDownloadFormats = window.ETahi.supportedDownloadFormats || data
        exportFormats = data.export_formats
        for dataType in exportFormats
          dataType.icon = "svg/#{dataType.format}-icon"
        controller.set('supportedDownloadFormats', exportFormats)

    if window.ETahi.supportedDownloadFormats
      return setFormats(window.ETahi.supportedDownloadFormats)

    Em.$.getJSON('/formats', setFormats)
