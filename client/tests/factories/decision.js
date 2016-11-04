import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('decision', {
  default: {
    draft: false,
    verdict: null,
    letter: null,
    minorVersion: null,
    majorVersion: null
  }
});
