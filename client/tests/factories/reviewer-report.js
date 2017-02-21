import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('reviewer-report', {
  default: {
    task: { id: 1 },
    decision: { id: 1},
    user: { id: 1}
  }
});
