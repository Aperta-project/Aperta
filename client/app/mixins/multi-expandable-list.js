import Ember from 'ember';

export default Ember.Mixin.create({
  // use a computed so we don't accidentally share instances of the array between components
  expanded: Ember.computed(() => []),

  isExpanded(thing) {
    return this.get('expanded').contains(thing.get('id'));
  },

  setExpanded(thing) {
    return this.get('expanded').addObject(thing.get('id'));
  },

  setUnexpanded(thing) {
    return this.get('expanded').removeObject(thing.get('id'));
  },

  toggleExpanded(thing) {
    if (this.isExpanded(thing)) {
      return this.setUnexpanded(thing);
    } else {
      return this.setExpanded(thing);
    }
  },

  actions: {
    isExpanded(thing) { return this.isExpanded(thing); },
    toggleExpanded(thing) { return this.toggleExpanded(thing); }
  }
});
