import Ember from 'ember';

export default Ember.Component.extend({
  classNameBindings: [
    ':task-disclosure',
    'taskVisible:task-disclosure--open'
  ],

  taskVisible: false,

  title: null,
  completed: false,

  actions: {
    toggleVisibility() {
      this.toggleProperty('taskVisible');
    }
  }
});
