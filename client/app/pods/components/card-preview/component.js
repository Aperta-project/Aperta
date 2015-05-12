import Ember from 'ember';

export default Ember.Component.extend({
  classNameBindings: [':card', 'task.completed:card--completed', 'classes'],

  paper: null,
  task: null,
  classes: '',
  canRemoveCard: false,
  defaultCommentLooks: [],
  commentLooks: Ember.computed.oneWay('defaultCommentLooks'),

  unreadCommentsCount: function() {
    let taskId = this.get('task.id');
    return this.get('commentLooks').filter(function(look) {
      return look.get('taskId') === taskId && Ember.isEmpty(look.get('readAt'));
    }).get('length');
  }.property('commentLooks.[]', 'commentLooks.@each.taskId', 'task.id', 'commentLooks.@each.readAt'),

  actions: {
    viewCard(task) {
      this.sendAction('action', task);
    },
    promptDelete(task) {
      this.sendAction('showDeleteConfirm', task);
    }
  }
});
