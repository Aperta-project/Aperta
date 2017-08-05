import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

export default TaskComponent.extend({
  contentRoot: Ember.computed.reads('task.cardVersion.contentRoot'),
  renderAsDualColumn: Ember.computed.alias('task.cardVersion.contentRoot.renderAsDualColumn')
});
