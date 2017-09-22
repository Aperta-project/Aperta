import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['scheduled-event-status'],
  defaultState: Ember.computed('event', function() {
    if (this.get('event.active')) {
      return { value: true };
    }
    else if (this.get('event.passive')){
      return { value: false };
    }
  }),
  actions: {
    changeEventState(newVal) {
      // console.log(newVal);
      if (newVal === true){
        // update event state to active
      }
      else if (newVal === false) {
        // update event state to passive
      }
    }
  }
});
