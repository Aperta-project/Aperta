import FactoryGuy from "ember-data-factory-guy";

FactoryGuy.define('paper-editor-task', {
  default: {
    title: 'Invite Editor',
    type: 'PaperEditorTask',
    completed: false,
  }
});
