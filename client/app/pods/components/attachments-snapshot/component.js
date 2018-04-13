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

import Ember from 'ember';
import {
  namedComputedProperty
} from 'tahi/lib/snapshots/snapshot-named-computed-property';
import SnapshotsById from 'tahi/lib/snapshots/snapshots-by-id'

import SnapshotAttachment from 'tahi/pods/snapshot/attachment/model';

export default Ember.Component.extend({
  attachments1: null,
  attachments2: null,

  children: Ember.computed(
    'attachments1.[]',
    'attachments2.[]',
    function(){
      let attachments1 = this.get('attachments1'),
        attachments2 = this.get('attachments2');
      let itemName;

      if(Ember.isPresent(attachments1)){
        itemName = attachments1[0].name;
      } else if(Ember.isPresent(attachments2)){
        itemName = attachments2[0].name;
      } else {
        return [];
      }

      var attachmentsById = new SnapshotsById(itemName);
      attachmentsById.addSnapshots(attachments1);
      attachmentsById.addSnapshots(attachments2);

      let results = attachmentsById.toArray().map( (pairs) => {
        let snapshotA = pairs[0],
          snapshotB = pairs[1];

        let snapshotAttachmentA, snapshotAttachmentB;
        if(snapshotA){
          snapshotAttachmentA = SnapshotAttachment.create({attachment: snapshotA});
        }

        if(snapshotB){
          snapshotAttachmentB = SnapshotAttachment.create({attachment: snapshotB});
        }

        return [snapshotAttachmentA, snapshotAttachmentB];
      });
      return results;
    }
  )
});
