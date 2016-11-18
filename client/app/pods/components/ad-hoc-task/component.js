import TaskComponent from 'tahi/pods/components/task-base/component';

export default TaskComponent.extend({
  actions: {
    sendEmail(data) {
      this.get('restless').putModel(this.get('task'), '/send_message', {
        task: data
      });

      this.send('save');
    }
  }
});
