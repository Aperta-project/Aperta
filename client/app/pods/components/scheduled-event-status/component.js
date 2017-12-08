import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['scheduled-event-status'],
  defaultState: Ember.computed('event', function() {
    return { value: this.get('event.active') };
  }),
  actions: {
    changeEventState(newVal) {
      const state = newVal ? 'active' : 'passive';
      this.set('event.state', state);
      this.get('event').save();
    }
  }
});
