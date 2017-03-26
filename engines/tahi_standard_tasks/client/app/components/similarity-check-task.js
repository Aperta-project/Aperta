import TaskComponent from 'tahi/pods/components/task-base/component';

export default TaskComponent.extend({
  classNames: ['similarity-check-task'],
  actions: {
    generateReport() {
      this.set('confirmVisible', true);
    },
    cancel() {
      this.set('confirmVisible', false);
    }
  }
});
