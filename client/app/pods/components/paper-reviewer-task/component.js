import TaskComponent from 'tahi/pods/components/task-base/component';
export default TaskComponent.extend({
  init() {
    this._super(...arguments);
    this.get('task.paper.decisions').reload();
  }
});
