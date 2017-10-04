import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('card-task-type', {
  default: {
    displayName: 'Custom Card',
    taskClass: 'CustomCardTask'
  }
});

