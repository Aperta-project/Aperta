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
      if (newVal === true){
        this.get('event').updateState('active');
      }
      else if (newVal === false) {
        this.get('event').updateState('passive');
      }
    }
  }
});
