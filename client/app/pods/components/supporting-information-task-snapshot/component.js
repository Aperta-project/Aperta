import Ember from 'ember';
import SnapshotsById from 'tahi/lib/snapshots/snapshots-by-id'

export default Ember.Component.extend({
  snapshot1: null,
  snapshot2: null,
  classNames: ['supporting-infomation-task-snapshot'],

  supportingInformationFiles: Ember.computed(
    'snapshot1',
    'snapshot2',
    function() {
      var snapshots = new SnapshotsById('supporting-information-file');
      snapshots.addSnapshots(this.get('snapshot1.children'));
      if (this.get('snapshot2.children')) {
        snapshots.addSnapshots(this.get('snapshot2.children'));
      }
      return snapshots.toArray();
    }
  )
});
