ETahi.FigureOverlayController = ETahi.TaskController.extend(ETahi.FileUploadMixin, {
  figureUploadUrl: ( ->
    "/papers/#{@get('litePaper.id')}/figures"
  ).property('litePaper.id')

  figures: Ember.computed.alias 'paper.figures'

  actions:
    uploadFinished: (data, filename) ->
      @uploadFinished(data, filename)

      @store.pushPayload('figure', data)
      figure = @store.getById('figure', data.figure.id)

      @get('figures').pushObject(figure)

    changeStrikingImage: (newValue) ->
      @get('content.paper').then (paper)->
        paper.set('strikingImageId', newValue).save()
})
