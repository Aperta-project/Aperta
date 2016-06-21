import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('billing-task', {
  default: {
    title: 'Billing',
    type: 'BillingTask',
    completed: false,
  }
});
