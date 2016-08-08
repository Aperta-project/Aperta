import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('register-decision-task', {
  default: {
    title: 'Register Decision',
    type: 'RegisterDecisionTask',
    completed: false
  }
});
