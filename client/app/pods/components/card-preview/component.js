import Ember from 'ember';
import ENV from 'tahi/config/environment';
import taskComponentName from 'tahi/lib/task-component-name';

export default Ember.Component.extend({
  classNames: ['card'],
  classNameBindings: ['task.completed:card--completed', 'classes', 'classComponentName'],
  
  classComponentName: Ember.computed('task.type', function() {
    return taskComponentName(this.get('task.type'));
  }),

  _propertiesCheck: Ember.on('init', function() {
    Ember.assert('You must pass a task property to the CardPreviewComponent', this.hasOwnProperty('task'));
  }),

  task: null,
  classes: '',
  canRemoveCard: false,
  version1: null,  // Will be a string like "1.2"
  version2: null,  // Will be a string like "1.2"

  // This is hack but the way we are creating a link but
  // not actually navigating to the link is non-ember-ish
  getRouter() {
    return this.container.lookup('router:main');
  },

  href: Ember.computed('task.id', function() {
    // Getting access to the router from tests is impossible, sorry
    if(ENV.environment === 'test' || Ember.testing) { return '#'; }

    const paper = this.get('task.paper');
    if(Ember.isEmpty(paper)) { return '#'; }

    const router = this.getRouter();
    const args = ['paper.task', paper, this.get('task')];
    return router.generate.apply(router, args);
  }),

  unreadCommentsCount: Ember.computed('task.commentLooks.[]', function() {
    // NOTE: this fn is also used for 'task-templates', who do
    // not have comment-looks
    return (this.get('task.commentLooks') || []).length;
  }),

  versioned: Ember.computed.notEmpty('version1'),

  hasDiff: Ember.computed(
    'version1',
    'version2',
    'task.paper.snapshots.[]',
    function() {
      if (this.get('version1') && this.get('version2')) {
        let paper =  this.get('task.paper');
        let task = this.get('task');
        let snap1 = paper.snapshotForTaskAndVersion(task, this.get('version1'));
        let snap2 = paper.snapshotForTaskAndVersion(task, this.get('version2'));
        return snap1 && snap1.hasDiff(snap2);
      }
      return false;
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
