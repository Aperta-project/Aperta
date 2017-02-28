import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('upload-manuscript-task', {
  default: {
    title: 'Upload Manuscript Task',
    type: 'UploadManuscriptTask',
    completed: false,
  }
});
