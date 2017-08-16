import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('export-delivery', {
  default: {
    state: 'pending',
    errorMessage: null,
    destination: 'apex'
  }
});
