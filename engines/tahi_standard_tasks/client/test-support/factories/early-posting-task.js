import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('early-posting-task', {
  default: {
    title: 'Early Article Posting',
    type: 'EarlyPostingTask',
    completed: false,
  }
});
