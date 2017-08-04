import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('scheduled-event', {
  default: {
    name: 'Test Event',
    state: null,
    dispatchAt: new Date('2017-08-19')
  }
});
