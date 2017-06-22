import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('admin-journal-role', {
  default: {
    name: 'Boss',
    assignedToTypeHint: 'Journal',
    cardPermissions: FactoryGuy.hasMany('card-permission')
  }
});
