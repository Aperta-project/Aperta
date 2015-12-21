import TaskComponent from 'tahi/pods/components/task-base/component';

export default TaskComponent.extend({
  actions: {
    sendToApex: function() {
      const apexDelivery = this.store.createRecord('apex-delivery', {
        task: this.get('task')
      });
      apexDelivery.save();
    }
  }
});
