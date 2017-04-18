import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('custom-card-task', {
  default: {
    title: 'My Custom Card',
    type: 'CustomCardTask',
    completed: false,
    cardVersion: FactoryGuy.belongsTo('card-version')
  }
});
