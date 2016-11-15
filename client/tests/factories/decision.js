import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('decision', {
  default: {
    draft: false,
    verdict: null,
    letter: null,
    registeredAt: new Date(),
    minorVersion: FactoryGuy.generate((num) => num),
    majorVersion: FactoryGuy.generate((num) => num)
  },
  traits: {
    draft: {
      draft: true,
      registeredAt: null,
      majorVersion: null,
      minorVersion: null
    }
  }
});
