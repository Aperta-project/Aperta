import Ember from 'ember';

export default Ember.Mixin.create({
  createThumbnail: Ember.on('didCreate', function() {
    const attrs = this.getProperties('completed', 'title', 'paper');
    attrs.taskType = this.get('type');

    const payload = {
      data: {
        id: this.get('id'),
        type: 'card-thumbnail',
        attributes: attrs
      }
    };

    this.store.push(payload);
    this.setThumbnailRelationship();
  }),

  updateThumbnail: Ember.on('didUpdate', function() {
    const thumbnail = this.store.peekRecord('card-thumbnail', this.get('id'));
    if (thumbnail) {
      thumbnail.set('completed', this.get('completed'));
    }
  }),

  deleteThumbnail: Ember.on('didDelete', function() {
    const thumbnail = this.store.peekRecord('card-thumbnail', this.get('id'));
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
    const thumbnail = this.store.peekRecord('card-thumbnail', this.get('id'));
    this.set('cardThumbnail', thumbnail);
  }
});
