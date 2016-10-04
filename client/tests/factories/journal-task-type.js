import FactoryGuy from 'ember-data-factory-guy';


FactoryGuy.define('journal-task-type', {
  default: {
    kind: 'AdHocTask',
    title: 'Ad-hoc Task'
  }
});
