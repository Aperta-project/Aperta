import Ember from 'ember';
import namedComputedProperty from 'tahi/mixins/components/snapshot-named-computed-property';

export default Ember.Component.extend({
  snapshot1: null,
  snapshot2: null,
  classNames: ['supporting-infomation-task-snapshot'],

  supportingInformationFiles: Ember.computed('snapshot1', 'snapshot2', function(){

    var pariedSnapshotValues = {};
    var snapshotId = function(snapshot){
      return _.find(snapshot.children, function(child){
        return child.name === 'id';
      }).value;
    };

    var setPairedSnapshot = function(id, value, snapshotNumber) {
      pairedSnapshotValues[id] = pairedSnapshotValues[id] || [null, null];
      pairedSnapshotValues[id][snapshotNumber] = value;
    };

    this.get('snapshot1.children').forEach(function(supportingInformationSnapshot){
      if (supportingInformationSnapshot.name !== 'supporting-information-file'){return;}
      let id = snapshotId(supportingInformationSnapshot);
      setPairedSnapshot(id, supportingInformationSnapshot, 0);
    })

    this.get('snapshot2.children').forEach(function(supportingInformationSnapshot){
      if (supportingInformationSnapshot.name !== 'supporting-information-file'){return;}
      let id = snapshotId(supportingInformationSnapshot);
      setPairedSnapshot(id, supportingInformationSnapshot, 1);
    })

    return _.values(pariedSnapshotValues);
  }),
})
