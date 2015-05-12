import Ember from 'ember';

export default Ember.Component.extend({
  classNameBindings: [':card', 'task.completed:card--completed', 'classes'],

  task: null,
  classes: '',
  canRemoveCard: false,

  unreadCommentsCount: function() {
    // note: this fn is also used for "task-templates", who do not have comment-looks
    return (this.get('task.commentLooks') || []).length;
  }.property('task.commentLooks.@each'),

  actions: {
    viewCard(task) {
      this.sendAction('action', task);
    },
    promptDelete(task) {
      this.sendAction('showDeleteConfirm', task);
    }
  }
});
