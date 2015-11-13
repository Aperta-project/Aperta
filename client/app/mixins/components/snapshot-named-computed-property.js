export default function namedComputedProperty(name) {
  return Ember.computed('snapshot.children.[]', function() {
    let parts = this.get('snapshot.children');
    return _.find(parts, function(part) {
      return part.name === name;
    }).value;
  });
};
