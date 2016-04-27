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
  constructor(itemName) {
    this.itemName = itemName;
    this.currentSnapshot = 0;
    this.pairedSnapshots = {};
  }

  snapshotId(snapshot){
    return _.findWhere(snapshot.children, {name: 'id'}).value;
  }

  setPairedSnapshot(id, value, snapshotNumber) {
    this.pairedSnapshots[id] = this.pairedSnapshots[id] || [];
    this.pairedSnapshots[id][snapshotNumber] = value;
  }

  addSnapshots(taskSnapshot) {
    if (!taskSnapshot){return;}

    _.each(this.pairedSnapshots, (list) => {
      list[this.currentSnapshot] = {};
    });

    taskSnapshot.forEach((childSnapshot) => {
      if (childSnapshot.name !== this.itemName) { return; }
      let id = this.snapshotId(childSnapshot);
      this.setPairedSnapshot(id, childSnapshot, this.currentSnapshot);
    });
    this.currentSnapshot++;
  }

  toArray() {
    return _.values(this.pairedSnapshots);
  }
}
