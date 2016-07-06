import Ember from 'ember';
import {
  namedComputedProperty
} from 'tahi/mixins/components/snapshot-named-computed-property';

let AttachmentSnapshot = Ember.Object.extend({
  snapshot: null,

  id: namedComputedProperty('snapshot', 'id'),
  file: namedComputedProperty('snapshot', 'file'),
  fileHash: namedComputedProperty('snapshot', 'file'),
  title: namedComputedProperty('snapshot', 'title'),
  caption: namedComputedProperty('snapshot', 'caption'),
  url: namedComputedProperty('snapshot', 'url')
});

export default Ember.Component.extend({
  attachments1: null,
  attachments2: null,

  snapshotAttachments1: Ember.computed('attachments.[]', function() {
    let attachments = this.get('attachments1');
    return Ember.makeArray(attachments).map( (attachment) => {
      return AttachmentSnapshot.create({snapshot: attachment});
    });
  }),
  snapshotAttachments2: Ember.computed('attachments.[]', function() {
    let attachments = this.get('attachments2');
    return Ember.makeArray(attachments).map( (attachment) => {
      return AttachmentSnapshot.create({snapshot: attachment});
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
