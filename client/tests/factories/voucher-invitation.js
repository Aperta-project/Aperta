import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('voucher-invitation', {
  extends: 'invitation',
  default: {
    token: 'random-strong-token',
    journalStaffEmail: 'email@example.com',
  },
});
