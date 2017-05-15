import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

export default TaskComponent.extend({
  contentRoot: Ember.computed.alias('task.cardVersion.contentRoot')
});
