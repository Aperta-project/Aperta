import Ember from 'ember';
import TaskComponent from 'tahi/pods/components/task-base/component';

export default TaskComponent.extend({
  contentRoot: Ember.computed.reads('task.cardVersion.contentRoot'),
  renderAsDualColumn: Ember.computed.reads('task.cardVersion.contentRoot.renderAsDualColumn'),

  init() {
    this._super(...arguments);
    this.get('task.paper.decisions').reload();
  }
});
