import TaskComponent from 'tahi/pods/components/task-base/component';

export default TaskComponent.extend({
  actions: {
    sendToApex: function() {
      const exportDelivery = this.get('store').createRecord('export-delivery', {
        task: this.get('task'),
        destination: 'apex'
      });
      exportDelivery.save();
    }
  }
});
