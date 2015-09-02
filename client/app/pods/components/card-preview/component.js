import Ember from 'ember';
import ENV from 'tahi/config/environment';
import DragNDrop from 'tahi/services/drag-n-drop';

export default Ember.Component.extend(DragNDrop.DraggableMixin, {
  classNameBindings: [':card', 'task.completed:card--completed', 'classes'],

  _propertiesCheck: Ember.on('init', function() {
    Ember.assert('You must pass a task property to the CardPreviewComponent', this.hasOwnProperty('task'));
  }),

  task: null,
  classes: '',
  canRemoveCard: false,

  dragStart() {
    DragNDrop.dragItem = this.get('task');
  },

  // This is hack but the way we are creating a link but
  // not actually navigating to the link is non-ember-ish
  getRouter() {
    return this.container.lookup('router:main');
  },

  href: Ember.computed(function() {
    // Getting access to the router from tests is impossible, sorry
    if(ENV.environment === 'test' || Ember.testing) { return '#'; }

    const paper = this.get('task.paper');
    if(Ember.isEmpty(paper)) { return '#'; }

    const router = this.getRouter();
    const args = ['paper.task', paper, this.get('task')];
    return router.generate.apply(router, args);
  }),

  unreadCommentsCount: Ember.computed('task.commentLooks.@each', function() {
    // NOTE: this fn is also used for 'task-templates', who do
    // not have comment-looks
    return (this.get('task.commentLooks') || []).length;
  }),

  actions: {
    viewCard() {
      this.sendAction('action', this.get('task'));
    },

    promptDelete() {
      this.sendAction('showDeleteConfirm', this.get('task'));
    }
  }
});
