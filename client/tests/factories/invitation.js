import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('invitation', {
  default: {
    state: 'invited',
    email: FactoryGuy.generate((num) => `user-${num}@example.com`),
    invitee: {},
    inviteeRole: 'Reviewer'
  }
});
