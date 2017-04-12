import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('card-version', {
  default: {
    card: FactoryGuy.belongsTo('card'),
    contentRoot: FactoryGuy.belongsTo('card-content')
  }
});
