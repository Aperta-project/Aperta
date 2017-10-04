import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('paper-task-type', {
  default: {
    kind: 'AdHocTask',
    title: 'Ad-hoc for Staff Only',
    rolehint: 'user',
    systemGenerated: true
  }
});

