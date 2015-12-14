import Task from 'tahi/models/task';

var SendToApexTask = Task.extend({
  apexDeliveries: DS.hasMany('apex-delivery')
});

export default SendToApexTask;
