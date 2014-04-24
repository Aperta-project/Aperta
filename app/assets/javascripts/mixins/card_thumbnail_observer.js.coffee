ETahi.CardThumbnailObserver = Ember.Mixin.create
  createThumbnail: ( ->
    thumbnailParams = @getProperties('id', 'completed', 'title')
    thumbnailParams.taskType = @get('type')
    @store.createRecord('cardThumbnail', thumbnailParams)
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
