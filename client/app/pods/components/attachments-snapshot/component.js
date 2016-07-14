import Ember from 'ember';
import {
  namedComputedProperty
} from 'tahi/lib/snapshots/snapshot-named-computed-property';
import SnapshotsById from 'tahi/lib/snapshots/snapshots-by-id'

import SnapshotAttachment from 'tahi/models/snapshot/attachment';

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
