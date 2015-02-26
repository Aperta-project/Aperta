// import DS   from 'ember-data';
import Task from 'tahi/models/task';

var BillingCardTask = Task.extend({
  qualifiedType: "BillingCard::BillingCardTask",
  billingDetail: DS.hasMany('billingDetail')
})
export default BillingCardTask;

// export default Task.extend({});
