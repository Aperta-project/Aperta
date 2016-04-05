import Ember from 'ember';

export const fromProperty = function(properties, name) {
  let property = _.findWhere(properties, { name: name } );
  if (property && property.value) {
    return property.value;
  }
  return ' ';
};

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
  return Ember.computed(snapshotName + '.[]', function() {
    return fromProperty(this.get(snapshotName), propertyName);
  });
};
