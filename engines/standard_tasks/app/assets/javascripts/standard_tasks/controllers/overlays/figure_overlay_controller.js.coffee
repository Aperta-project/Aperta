ETahi.FigureOverlayController = ETahi.TaskController.extend ETahi.FileUploadMixin,
  figureUploadUrl: ( ->
    "/papers/#{@get('litePaper.id')}/figures"
  ).property('litePaper.id')

  figures: ( ->
    figures = @get('paper.figures') || []
    figures.sortBy('createdAt').reverse()
  ).property('paper.figures.@each')

  actions:
    uploadFinished: (data, filename) ->
      @uploadFinished(data, filename)

      @store.pushPayload('figure', data)
      figure = @store.getById('figure', data.figure.id)

      @get('paper.figures').pushObject(figure)

    changeStrikingImage: (newValue) ->
      @get('paper').set('strikingImageId', newValue)

    updateStrikingImage: ->
      @get('paper').save()
