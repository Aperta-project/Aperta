import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['scheduled-event-status'],
  defaultState: Ember.computed('event', function() {
    if (this.get('event.active')) {
      return { value: true };
    }
    else {
      return { value: false };
    }
  }),
});
