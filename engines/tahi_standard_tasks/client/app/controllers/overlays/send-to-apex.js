import TaskController from 'tahi/pods/paper/task/controller';

var SendToApexOverlayController = TaskController.extend({
  actions: {
    sendToApex: function() {
      let apexDelivery = this.store.createRecord('apex-delivery', {
        task: this.get('model')
      });
      apexDelivery.save();
    }
  }
});

export default SendToApexOverlayController;
