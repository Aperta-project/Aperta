import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('figure-task', {
  default: {
    title: 'Figure',
    type: 'FigureTask',
    completed: false,
  }
});
