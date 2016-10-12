import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('question-attachment', {
  default: {
    filename: 'test.jpg',
    src: 's3/test.jpg',
    status: 'done',
    title: 'Test file',
    caption: 'A test file'
  }
});
