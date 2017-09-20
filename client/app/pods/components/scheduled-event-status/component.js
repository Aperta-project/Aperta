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

      // this is the part where we make a call to the endpoint to set the event to true or false
    }
  }
});
