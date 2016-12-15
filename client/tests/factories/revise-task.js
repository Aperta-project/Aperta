import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('revise-task', {
  default: {
    title: 'Revise Manuscript',
    type: 'ReviseTask',
    completed: false,
  }
});
