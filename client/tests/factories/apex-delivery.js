import FactoryGuy from 'ember-data-factory-guy';


FactoryGuy.define('apex-delivery', {
  default: {
    state: 'pending',
    errorMessage: null,
    destination: 'apex'
  }
});
