// When diffing figures, Authors, and Supporting information, among others, we
// face a funny problem when an item is deleted. If we just compare each pair of
// snapshots in order, the items get mis-aligned, and every item after the
// deleted one shows a diff, even when the item is actually unchanged. So we
// must pair our snapshots up by *id*, not by position. This is a helper class
// to make that pairing fast and easy.
//
// See supporting-information-task-snapshot/component.js to see it in action.
//
export default class SnapshotsById {
  constructor(taskName) {
    this.taskName = taskName;
    this.currentSnapshot = 0;
    this.pairedSnapshots = {};
  }

  snapshotId(snapshot){
    return _.find(snapshot.children, function(child){
      return child.name === 'id';
    }).value;
  }

  setPairedSnapshot(id, value, snapshotNumber) {
    this.pairedSnapshots[id] = this.pairedSnapshots[id] || [];
    this.pairedSnapshots[id][snapshotNumber] = value;
  }

  addSnapshots(taskSnapshot) {
    if (!taskSnapshot){return;}

    taskSnapshot.forEach((childSnapshot) => {
      if (childSnapshot.name !== this.taskName) { return; }
      let id = this.snapshotId(childSnapshot);
      this.setPairedSnapshot(id, childSnapshot, this.currentSnapshot);
    });
    this.currentSnapshot++;
  }

  toArray() {
    return _.values(this.pairedSnapshots);
  }
};
