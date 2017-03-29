import Ember from 'ember';
import DS from 'ember-data';
import Snapshottable from 'tahi/mixins/snapshottable';

export default DS.Model.extend(Snapshottable, {
  restless: Ember.inject.service('restless'),
  decision: DS.belongsTo('decision', { async: false, inverse: 'attachments' }),
  src: DS.attr('string'),
  status: DS.attr('string'),
  title: DS.attr('string'),

  cancelUpload() {
    this.deleteRecord();
    return this.get('restless').put(`/api/attachments/${this.get('id')}/cancel`);
  }
});
