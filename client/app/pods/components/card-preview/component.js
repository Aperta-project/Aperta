import Ember from 'ember';

export default Ember.Component.extend({
  classNameBindings: [':card', 'task.completed:card--completed', 'classes'],

  // TODO: The templates always pass an attr of paper but it is never used

  _propertiesCheck: Ember.on('init', function() {
    Ember.assert('You must pass a task property to the CardPreviewComponent', this.hasOwnProperty('task'));
  }),

  task: null,
  classes: '',
  canRemoveCard: false,

  unreadCommentsCount: Ember.computed('task.commentLooks.@each', function() {
    // NOTE: this fn is also used for 'task-templates', who do
    // not have comment-looks
    return (this.get('task.commentLooks') || []).length;
  }),

  actions: {
    viewCard(task) {
      this.sendAction('action', this.get('task'));
    },

    promptDelete(task) {
      this.sendAction('showDeleteConfirm', this.get('task'));
    }
  }
});
