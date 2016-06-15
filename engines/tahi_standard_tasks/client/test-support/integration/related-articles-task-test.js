import {moduleForComponent, test} from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';
// Pretend like you're in client/tests
import FakeCanService from '../helpers/fake-can-service';


moduleForComponent(
  'related-articles-task',
  'Integration | Components | Tasks | Related Articles', {
  integration: true
});


test('User can add a new related article', function(assert){
  assert.expect(5);

  var task = newTask();
  task.paper.relatedArticles = [];

  stubStoreCreateRecord((type, properties) => {
    assert.equal(type, 'related-article', 'Creates a related article');
    assert.equal(properties.paper, task.paper, 'Connects to the paper');

    return this.get('task.paper.relatedArticles').pushObject(newArticle());
  }, this);

  setupEditableTask(this, task);

  assert.elementFound('.related-article-task-add', 'The add button is present');

  this.$('.related-article-task-add').click();

  assert.elementFound('.related-article', 'New related article is visible');

  assert.elementFound(
    '.related-article .related-article-title-input',
    'New article is opened for editing');
});


test('User can see existing related articles', function(assert){
  var article = newExistingArticle();
  var task = newTask();
  task.paper.relatedArticles = [article];
  setupEditableTask(this, task);

  assert.elementFound('.related-article', 'Related article is visible');

  assert.textPresent(
    '.related-article .related-article-title',
    article.linkedTitle);
});


var newExistingArticle = function() {
  return {
    id: 3,
    linkedDOI: 'journal.pcbi.1004816',
    linkedTitle: 'The best linked article in texas',
    additionalInfo: 'This information is additional',
    sendManuscriptsTogether: true,
    sendLinkToApex: true
  };
};

var newArticle = function() {
  return {
    linkedDOI: '',
    linkedTitle: '',
    additionalInfo: '',
    sendManuscriptsTogether: undefined,
    sendLinkToApex: undefined,
    isNew: true
  };
};

var newTask = function() {
  return {
    id: 2,
    title: 'Related Articles',
    type: 'TahiStandardTasks::RelatedArticles',
    completed: false,
    isMetadataTask: false,
    isSubmissionTask: false,
    assignedToMe: false,
    paper: {
      relatedArticles: []
    }
  };
};

var stubStoreCreateRecord = function(fn, context) {
  context.register('service:store', Ember.Object.extend({
    createRecord: fn
  }));
};

var template = hbs`{{related-articles-task task=task can=can container=container}}`;

var setupEditableTask = function(context, task) {
  task = task || newTask();
  var can = FakeCanService.create();
  can.allowPermission('edit', task);

  context.setProperties({
    can: can,
    task: task
  });

  context.render(template);
};
