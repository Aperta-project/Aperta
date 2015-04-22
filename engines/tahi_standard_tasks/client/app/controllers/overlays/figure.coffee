`import TaskController from 'tahi/pods/task/controller'`
`import FileUploadMixin from 'tahi/mixins/file-upload'`

FigureOverlayController = TaskController.extend FileUploadMixin,
  figureUploadUrl: ( ->
    "/api/papers/#{@get('paper.id')}/figures"
  ).property('paper.id')

  figures: ( ->
    figures = @get('paper.figures') || []

    # TODO: When ember data is updated, remove this.
    # Ember Data v1.0.0-beta.15-canary
    figures = figures.filter( (figure) ->
      !figure.get 'isDeleted'
    )
    figures.sortBy('createdAt').reverse()
  ).property('paper.figures.[]', 'paper.figures.@each.createdAt')

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

    destroyAttachment: (attachment) ->
      @get('paper.figures').removeObject(attachment)
      attachment.destroyRecord()

`export default FigureOverlayController`
