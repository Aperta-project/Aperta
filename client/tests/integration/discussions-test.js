import Ember from 'ember';
import { module, test } from 'qunit';
import startApp from 'tahi/tests/helpers/start-app';
import { make } from 'ember-data-factory-guy';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';

let App = null;
let paper, topic;

module('Integration: Discussions', {
  afterEach: function() {
    Ember.run(function() {
      TestHelper.teardown();
      App.destroy();
    });
  },

  beforeEach: function() {
    App = startApp();
    TestHelper.setup(App);

    paper = make('paper', { phases: [], tasks: [] });
    topic = make('discussion-topic', { paperId: paper.id, title: 'Hipster Ipsum Dolor' });

    TestHelper.handleFind(paper);
    TestHelper.handleFindAll('discussion-topic', 1);
  }
});

test('can see a list of topics', function(assert) {
  Ember.run(function() {
    visit('/papers/' + paper.id + '/workflow/discussions/');

    andThen(function() {
      assert.ok(find('.discussions-index-topic').length, 'Topic is found');
    });
  });
});

// test('can add a new topic', function(assert) {
//   Ember.run(function() {
//     let topicTitle   = 'Tech Check Discussion';
//     let firstComment = 'We need to talk about this, yous guys.';
// 
//     TestHelper.handleFindAll('discussion-topic', 1);
//     TestHelper.handleCreate('discussion-topic');
// 
//     visit('/papers/' + paper.id + '/workflow/discussions/');
//     click('a:contains("Create New Topic")');
//     fillIn('.discussion-topic-title-field', topicTitle);
//     fillIn('.discussion-topic-comment-field', firstComment);
//     click('button:contains("Create Topic")');
// 
//     andThen(function() {
//       assert.ok(find('.discussions-show-title:contains("' + topicTitle + '")').length, 'New topic is found');
//       assert.ok(find('.message-comment:contains("' + firstComment + '")').length, 'First comment is found');
//     });
//   });
// });
