import Ember from 'ember';
import TaskController from 'tahi/pods/paper/task/controller';

export default TaskController.extend({
  queryParams: ['selectedVersion1', 'selectedVersion2'],

  selectedVersion1Snapshot: Ember.computed('model', 'selectedVersion1', function(){
    return this.get('model').getSnapshotForVersion(this.get('selectedVersion1'));
  }),

  selectedVersion2Snapshot: Ember.computed('model', 'selectedVersion2', function(){
    return this.get('model').getSnapshotForVersion(this.get('selectedVersion2'));
  })
});
