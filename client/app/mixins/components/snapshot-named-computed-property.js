import Ember from 'ember';

export const fromProperty = function(properties, name) {
  let property = _.findWhere(properties, { name: name } );
  if (property && property.value) {
    return property.value;
  }
  return ' ';
};

export const getNamedComputedProperty = function(collectionKey, propertyKey) {
  return Ember.computed(collectionKey + '.[]', function() {
    return fromProperty(this.get(collectionKey), propertyKey);
  });
};

export const fromQuestion = function(collectionKey, propertyKey) {
  return Ember.computed(collectionKey + '.[]', function() {
    let properties = this.get(collectionKey);
    let question = _.findWhere(properties, { name: propertyKey });
    if (question && question.value && question.value.answer === true) {
      return question.value.title + ' Yes';
    }
    return ' ';
  });
};

export default function namedComputedProperty(name) {
  return getNamedComputedProperty('snapshot.children', name);
}

