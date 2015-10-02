import FactoryGuy from "ember-data-factory-guy";

FactoryGuy.define('authors-task', {
  default: {
    title: 'Authors',
    type: 'AuthorsTask',
    completed: false
  }
});
