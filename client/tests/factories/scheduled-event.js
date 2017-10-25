import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('scheduled-event', {
  sequences: {
    name: (num)=> `Test Event${num}`
  },
  default: {
    name: FactoryGuy.generate('name'),
    state: null,
    dispatchAt: new Date('2017-08-19')
  }
});
