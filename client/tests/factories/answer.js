import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('answer', {
  default: {},
  traits: {}
});

// createAnswer expects the owner and the cardContent
// with the given ident to already be in the store
export function createAnswer(owner, ident, attrs) {
  return FactoryGuy.make('answer', Object.assign(attrs, {
    owner: owner,
    cardContent: FactoryGuy.store.peekCardContent(ident)
  }));
}
