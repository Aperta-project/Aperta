import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('paper-task-type', {
  polymorphic: false,
  default: {
    kind: 'AdHocTask',
    title: 'Ad-hoc for Staff Only',
    rolehint: 'user',
    systemGenerated: true
  }
});

