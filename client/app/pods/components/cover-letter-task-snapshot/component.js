import Ember from 'ember';
import SnapshotAttachment from 'tahi/models/snapshot/attachment';
import { namedComputedProperty } from 'tahi/lib/snapshots/snapshot-named-computed-property';

export default Ember.Component.extend({
  snapshot1: null,
  snapshot2: null,
  classNames: ['cover-letter-snapshot'],

  attachment1: Ember.computed('snapshot1', function(){
    let children = this.get('snapshot1.children');
    if (children) {
      let attachment = children.findBy('name', 'cover_letter--attachment');
      if(attachment && attachment.value && attachment.value.attachments){
        attachment = attachment.value.attachments[0];
        return SnapshotAttachment.create({attachment: attachment});
      }
    }
  }),
  
  attachment2: Ember.computed('snapshot2', function(){
    let children = this.get('snapshot2.children');
    if (children) {
      let attachment = children.findBy('name', 'cover_letter--attachment');
      if(attachment && attachment.value && attachment.value.attachments){
        attachment = attachment.value.attachments[0];
        return SnapshotAttachment.create({attachment: attachment});
      }
    }
  }),

  text1: namedComputedProperty('snapshot1', 'cover_letter--text'),
  text2: namedComputedProperty('snapshot2', 'cover_letter--text'),

});
