import Ember from 'ember';

export default Ember.Component.extend({
  classNameBindings: [
    ':task-disclosure',
    'taskVisible:task-disclosure--open',
    'task.completed:completed'
  ],

  taskVisible: false,

  _propertiesCheck: Ember.on('init', function() {
    Ember.assert('You must pass a task property to the TaskDisclosureComponent', this.hasOwnProperty('task'));
  }),

  task: null,

  unreadCommentsCount: Ember.computed('task.commentLooks.[]', function() {
    return this.get('task.commentLooks').length;
  }),

  actions: {
    toggleVisibility() {
      this.toggleProperty('taskVisible');
    }
  }
});

