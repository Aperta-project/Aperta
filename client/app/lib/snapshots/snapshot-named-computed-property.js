import Ember from 'ember';
import SnapshotAttachment from 'tahi/models/snapshot/attachment';

export const diffableTextForQuestion = function(collectionKey, propertyKey) {
  return Ember.computed(collectionKey + '.[]', function() {
    let properties = this.get(collectionKey);
    let question = _.findWhere(properties, { name: propertyKey });
    if (question && question.value && question.value.answer === true) {
      return question.value.title + ' Yes';
    }
    return ' ';
  });
};

export const namedComputedProperty = function(snapshotName, propertyName) {
  return Ember.computed(snapshotName + '.children.[]', function() {

    var properties = this.get(snapshotName + '.children');
    if (!properties) { return null; }

    let property = _.findWhere(properties, { name: propertyName } );
    if (!property) { return null; }

    return property.value;
  });
};

export const namedComputedAttachmentProperty = function(snapshotName, propertyName){
  return Ember.computed(snapshotName + '.children.[]', function() {
    let children = this.get(`${snapshotName}.children`);
    if (children) {
      let property = children.findBy('name', propertyName);
      if(property && property.value && property.value.attachments){
        let attachment = property.value.attachments[0];
        return SnapshotAttachment.create({attachment: attachment});
      }
    }
  });
};
