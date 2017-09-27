import Ember from 'ember';
import DS from 'ember-data';
import Snapshottable from 'tahi/mixins/snapshottable';

export default DS.Model.extend(Snapshottable, {
  restless: Ember.inject.service('restless'),
  paper: DS.belongsTo('paper'),
  task: DS.belongsTo('task', { async: false, polymorphic: true, inverse: 'attachments' }),
  caption: DS.attr('string'),
  filename: DS.attr('string'),
  fileType: DS.attr('string'),
  status: DS.attr('string'),
  title: DS.attr('string'),

  cancelUploadPath() {
    return `/api/attachments/${this.get('id')}/cancel`;
  },

  cancelUpload() {
    this.deleteRecord();
    return this.get('restless').put(this.cancelUploadPath());
  }
});
