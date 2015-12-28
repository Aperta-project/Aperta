import TaskComponent from 'tahi/pods/components/task-base/component';

export default TaskComponent.extend({
  actions: {
    savePaperShortTitle() {
      this.get('task.paper').save();
    }
  }
});
