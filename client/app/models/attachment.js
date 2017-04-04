import Ember from 'ember';
import DS from 'ember-data';
import Snapshottable from 'tahi/mixins/snapshottable';

export default DS.Model.extend(Snapshottable, {
  restless: Ember.inject.service('restless'),
  task: DS.belongsTo('task', { async: false, polymorphic: true, inverse: 'attachments' }),
  captionHtml: DS.attr('string'),
  filename: DS.attr('string'),
  fileType: DS.attr('string'),
  status: DS.attr('string'),
  titleHtml: DS.attr('string'),

  cancelUpload() {
    this.deleteRecord();
    return this.get('restless').put(`/api/attachments/${this.get('id')}/cancel`);
  }
});
