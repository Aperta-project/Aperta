/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

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
