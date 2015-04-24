`import Ember from 'ember'`

CardThumbnailObserver = Ember.Mixin.create
  createThumbnail: ( ->
    thumbnailParams = @getProperties('id', 'completed', 'title', 'paper')
    thumbnailParams.taskType = @get('type')
    @store.push('cardThumbnail', thumbnailParams)
    @setThumbnailRelationship()
  ).on('didCreate')

  updateThumbnail: ( ->
    thumbnail = @store.getById('cardThumbnail', @get('id'))
    if thumbnail
      thumbnail.set('completed', @get('completed'))
  ).on('didUpdate')

  deleteThumbnail: ( ->
    thumbnail = @store.getById('cardThumbnail', @get('id'))
    if thumbnail
      thumbnail.deleteRecord()
  ).on('didDelete')

  upsertThumbnail: ( ->
    if @store.hasRecordForId('cardThumbnail', @get('id'))
      @updateThumbnail()
    else
      @createThumbnail()
    @setThumbnailRelationship()
  ).on('didLoad')

  setThumbnailRelationship: ->
    thumbnail = @store.getById('cardThumbnail', @get('id'))
    @set('cardThumbnail', thumbnail)

`export default CardThumbnailObserver`
