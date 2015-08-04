import Ember from 'ember';

export default Ember.Mixin.create({
  createThumbnail: function() {
    let thumbnailParams = this.getProperties('id', 'completed', 'title', 'paper');
    thumbnailParams.taskType = this.get('type');
    this.store.push('card-thumbnail', thumbnailParams);
    this.setThumbnailRelationship();
  }.on('didCreate'),

  updateThumbnail: function() {
    let thumbnail = this.store.getById('card-thumbnail', this.get('id'));
    if (thumbnail) {
      thumbnail.set('completed', this.get('completed'));
    }
  }.on('didUpdate'),

  deleteThumbnail: function() {
    let thumbnail = this.store.getById('card-thumbnail', this.get('id'));
    if (thumbnail) {
      thumbnail.deleteRecord();
    }
  }.on('didDelete'),

  upsertThumbnail: function() {
    if (this.store.hasRecordForId('card-thumbnail', this.get('id'))) {
      this.updateThumbnail();
    } else {
      this.createThumbnail();
    }

    this.setThumbnailRelationship();
  }.on('didLoad'),

  setThumbnailRelationship() {
    let thumbnail = this.store.getById('card-thumbnail', this.get('id'));
    this.set('cardThumbnail', thumbnail);
  }
});
