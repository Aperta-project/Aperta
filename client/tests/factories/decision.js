import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('decision', {
  default: {
    isLatest: true,
    verdict: null,
    letter: null,
    revisionNumber: null
  }
});
