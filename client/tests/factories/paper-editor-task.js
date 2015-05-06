import FactoryGuy from "ember-data-factory-guy";

FactoryGuy.define('paper-editor-task', {
  default: {
    title: 'Assign Editors',
    type: 'PaperEditorTask',
    completed: false,
  }
});
