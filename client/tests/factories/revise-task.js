import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('revise-task', {
  default: {
    title: 'Response to Reviewers',
    type: 'ReviseTask',
    completed: false,
  }
});
