import FactoryGuy from "ember-data-factory-guy";

FactoryGuy.define('plos-authors-task', {
  default: {
    title: 'Assign Editors',
    type: 'PlosAuthorsTask',
    completed: false,
  }
});
