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

import { module, test } from 'qunit';
import SnapshotsById from 'tahi/lib/snapshots/snapshots-by-id';

module('SnapshotsById');

var firstSnapshots = [{
  name: 'figure',
  children: [
   {name:'id', value:'foo'},
   {name:'important', value:'squid'},
  ]
}, {
  name: 'figure',
  children: [
   {name:'id', value:'bar'},
   {name:'important', value:'baboon'},
  ]
}]

var secondSnapshots = [{
  name: 'figure',
  children: [
   {name:'id', value:'foo'},
   {name:'important', value:'squid'},
  ]
}, {
  name: 'figure',
  children: [
   {name:'id', value:'bar'},
   {name:'important', value:'CHANGED baboon'},
  ]
}]

test('constructor', function(assert) {
  var subject = new SnapshotsById('figure');
  assert.equal(subject.itemName, 'figure', 'Stores item name');
  assert.equal(subject.currentSnapshot, 0, 'Starts at the 0th snapshot');
  assert.equal(_.keys(subject.pairedSnapshots).length,
               0,
               'Starts with no stored snapshots');
});

test('snapshotId', function(assert){
  var subject = new SnapshotsById('figure');
  var snapshot = firstSnapshots[0]
  assert.equal(subject.snapshotId(snapshot),
               'foo',
               'Returns the id of the snapshot');
})

test('setPairedSnapshot', function(assert) {
  var subject = new SnapshotsById('figure');
  subject.setPairedSnapshot(5, 'value!', 0);
  subject.setPairedSnapshot(5, 'second value!', 1);
  assert.equal(subject.pairedSnapshots[5][0],
               'value!',
               'Inserts a value by id and number');

  assert.equal(subject.pairedSnapshots[5][1],
               'second value!',
               'Inserts additional values by id and number');
});

test('addSnapshots', function(assert) {
  var subject = new SnapshotsById('figure');
  assert.equal(subject.addSnapshots(),
               undefined,
               'Returns without a taskSnapshot');

  subject.addSnapshots(firstSnapshots);
  assert.equal(subject.currentSnapshot, 1, 'Current Snapshot increments by 1');

  subject.addSnapshots(secondSnapshots);
  assert.equal(subject.currentSnapshot, 2, 'Current Snapshot increments by 1');

  assert.equal(subject.pairedSnapshots['foo'][0], firstSnapshots[0]);
  assert.equal(subject.pairedSnapshots['foo'][1], secondSnapshots[0]);
});

test('toArray', function(assert) {
  var subject = new SnapshotsById('figure');
  subject.addSnapshots(firstSnapshots);
  subject.addSnapshots(secondSnapshots);
  assert.equal(subject.toArray()[0][0],
               firstSnapshots[0],
               'Returns an array of matched snapshots');
  assert.equal(subject.toArray()[0][1],
              secondSnapshots[0],
              'Returns an array of matched snapshots');

});
