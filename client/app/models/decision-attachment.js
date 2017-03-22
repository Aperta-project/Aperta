import Ember from 'ember';
import DS from 'ember-data';
import Snapshottable from 'tahi/mixins/snapshottable';

export default DS.Model.extend(Snapshottable, {
  restless: Ember.inject.service('restless'),
  file: DS.attr(),
  status: DS.attr('string'),
  title: DS.attr('string'),

  cancelUpload() {
    this.deleteRecord();
    return this.get('restless').put(`/api/attachments/${this.get('id')}/cancel`);
  }
});
