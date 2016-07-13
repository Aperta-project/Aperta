import Ember from 'ember';
import {
  namedComputedProperty
} from 'tahi/lib/snapshots/snapshot-named-computed-property';

import SnapshotAttachment from 'tahi/models/snapshot/attachment';

export default Ember.Component.extend({
  attachments1: null,
  attachments2: null,

  snapshotAttachments1: Ember.computed('attachments.[]', function() {
    let attachments = this.get('attachments1');
    return Ember.makeArray(attachments).map( (attachment) => {
      return SnapshotAttachment.create({attachment: attachment});
    });
  }),
  snapshotAttachments2: Ember.computed('attachments.[]', function() {
    let attachments = this.get('attachments2');
    return Ember.makeArray(attachments).map( (attachment) => {
      return SnapshotAttachment.create({attachment: attachment});
    });
  }),

  children: Ember.computed(
    'snapshotAttachments1.[]',
    'snapshotAttachments2.[]',
    function(){
      let snapshots1 = this.get('snapshotAttachments1'),
        snapshots2 = this.get('snapshotAttachments2');

      let orderedSnapshots2 = Ember.makeArray();
      snapshots1.forEach( (snapshot) => {
        orderedSnapshots2.push(snapshots2.findBy('id', snapshot.get('id')));
      });

      return _.zip(snapshots1, orderedSnapshots2);
    }
  )
});
