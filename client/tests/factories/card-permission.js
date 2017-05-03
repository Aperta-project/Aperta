import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('card-permission', {
  default: {
    roles: FactoryGuy.hasMany('admin-journal-role'),
    filterByCardId: '1',
    permissionAction: 'view'
  }
});
