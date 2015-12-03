import Ember from 'ember';
import TaskController from 'tahi/pods/paper/task/controller';

export default TaskController.extend({
  queryParams: ['selectedVersion1', 'selectedVersion2'],

  snapshot: Ember.computed('model', 'majorVersion', 'minorVersion', function(){
    return this.get('model').getSnapshotForVersion(
      this.get('majorVersion'),
      this.get('minorVersion')
    );
  })
});
