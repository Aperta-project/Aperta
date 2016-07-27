import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('decision', {
  default: {
    latest: true,
    verdict: null,
    letter: null,
    minorVersion: null,
    majorVersion: null
  }
});
