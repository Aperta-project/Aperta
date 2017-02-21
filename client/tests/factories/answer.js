import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('answer', {
  default: {},
  traits: {}
});

export function createAnswer(owner, ident, attrs) {
  return FactoryGuy.make('answer', Object.assign(attrs, {
    owner: owner,
    cardContent: FactoryGuy.store.peekCardContent(ident)
  }));
}
