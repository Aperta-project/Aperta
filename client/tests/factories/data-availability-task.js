import FactoryGuy from "ember-data-factory-guy";

FactoryGuy.define('data-availability-task', {
  default: {
    title: 'Data Availability',
    type: 'DataAvailabilityTask',
    completed: false
  }
});
