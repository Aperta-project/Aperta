import Ember from 'ember';
import SnapshotsById from 'tahi/lib/snapshots/snapshots-by-id'

export default Ember.Component.extend({
  snapshot1: null,
  snapshot2: null,
  classNames: ['supporting-infomation-task-snapshot'],

  supportingInformationFiles1: Ember.computed('snapshot1', function(){
    return Ember.makeArray(this.get('snapshot1.children'))
      .filterBy('name', 'supporting-information-file');
  }),

  supportingInformationFiles2: Ember.computed('snapshot2', function(){
    return Ember.makeArray(this.get('snapshot2.children'))
      .filterBy('name', 'supporting-information-file');
  }),
});
