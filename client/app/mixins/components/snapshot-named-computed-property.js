import Ember from 'ember';

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
