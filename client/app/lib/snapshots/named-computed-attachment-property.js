import Ember from 'ember';
import SnapshotAttachment from 'tahi/pods/snapshot/attachment/model';

export default function(snapshotName, propertyName){
  return Ember.computed(snapshotName + '.children.[]', function() {
    let children = this.get(snapshotName + '.children');
    if (children) {
      let property = children.findBy('name', propertyName);
      if(property && property.value && property.value.attachments){
        let attachment = property.value.attachments[0];
        return SnapshotAttachment.create({attachment: attachment});
      }
    }
  });
}
