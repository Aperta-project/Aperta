import Ember from 'ember';

export default Ember.Mixin.create({
  createThumbnail: Ember.on('didCreate', function() {
    let thumbnailParams = this.getProperties('id', 'completed', 'title', 'paper');
    thumbnailParams.taskType = this.get('type');
    this.store.push('card-thumbnail', thumbnailParams);
    this.setThumbnailRelationship();
  }),

  updateThumbnail: Ember.on('didUpdate', function() {
    let thumbnail = this.store.peekRecord('card-thumbnail', this.get('id'));
    if (thumbnail) {
      thumbnail.set('completed', this.get('completed'));
    }
  }),

  deleteThumbnail: Ember.on('didDelete', function() {
    let thumbnail = this.store.peekRecord('card-thumbnail', this.get('id'));
    if (thumbnail) {
      thumbnail.deleteRecord();
    }
  }),

  upsertThumbnail: Ember.on('didLoad', function() {
    if (this.store.hasRecordForId('card-thumbnail', this.get('id'))) {
      this.updateThumbnail();
    } else {
      this.createThumbnail();
    }

    this.setThumbnailRelationship();
  }),

  setThumbnailRelationship() {
    let thumbnail = this.store.peekRecord('card-thumbnail', this.get('id'));
    this.set('cardThumbnail', thumbnail);
  }
});
