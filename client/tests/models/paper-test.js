import Ember from 'ember';
import { test, moduleForModel } from 'ember-qunit';
import startApp from 'tahi/tests/helpers/start-app';
import FactoryGuy from 'ember-data-factory-guy';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';

var App;

moduleForModel('paper', 'Unit: Paper Model', {
  needs: ['model:author', 'model:user', 'model:figure', 'model:table', 'model:bibitem', 'model:journal', 'model:decision', 'model:invitation', 'model:affiliation', 'model:attachment', 'model:question-attachment', 'model:comment-look', 'model:discussion-topic', 'model:versioned-text', 'model:discussion-participant', 'model:discussion-reply', 'model:phase', 'model:task', 'model:comment', 'model:participation', 'model:card-thumbnail', 'model:nested-question-owner', 'model:nested-question', 'model:nested-question-answer', 'model:collaboration', 'model:supporting-information-file'],
  afterEach: function() {
    Ember.run(function() {
      return TestHelper.teardown();
    });
    return Ember.run(App, "destroy");
  },
  beforeEach: function() {
    App = startApp();
    return TestHelper.setup(App);
  }
});

test('displayTitle displays short title if title is missing', function(assert) {
  var shortTitle;
  shortTitle = 'test short title';
  var paper = FactoryGuy.make("paper", {
    title: "",
    shortTitle: shortTitle
  });
  assert.equal(paper.get('displayTitle'), shortTitle);
});

test('displayTitle displays title if present', function(assert) {
  var title;
  title = 'Test Title';
  var paper = FactoryGuy.make("paper", {
    title: title,
    shortTitle: ""
  });
  assert.equal(paper.get('displayTitle'), title);
});


test('simplifiedRelatedUsers contains no collaborators', function(assert) {
  var title;
  title = 'Test Title';
  var paper = FactoryGuy.make('paper', {
    title: title,
    shortTitle: '',
    relatedUsers: [
      {name: 'Creator', users: []},
      {name: 'Collaborator', users: []}
    ]
  });
  assert.equal(paper.get('simplifiedRelatedUsers.length'), 1);
  let remaining = paper.get('simplifiedRelatedUsers').objectAt(0).name;
  assert.equal(remaining, 'Creator');
});
