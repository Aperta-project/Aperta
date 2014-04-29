ETahi.CardThumbnailObserver = Ember.Mixin.create
  createThumbnail: ( ->
    thumbnailParams = @getProperties('id', 'completed', 'title', 'litePaper')
    thumbnailParams.taskType = @get('type')
    @store.push('cardThumbnail', thumbnailParams)
  ).on('didCreate')

  updateThumbnail: ( ->
    thumbnail = @store.getById('cardThumbnail', @get('id'))
    if thumbnail
      thumbnail.set('completed', @get('completed'))
      thumbnail.set('assigneeId', @get('assignee.id'))
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
  ).on('didLoad')
