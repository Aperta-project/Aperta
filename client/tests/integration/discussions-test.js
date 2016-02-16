import Ember from 'ember';
import { module, test } from 'qunit';
import startApp from 'tahi/tests/helpers/start-app';
import { make } from 'ember-data-factory-guy';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';

let App = null;
let paper, topic;

module('Integration: Discussions', {
  afterEach: function() {
    Ember.run(function() { TestHelper.teardown(); });
    Ember.run(App, 'destroy');
  },

  beforeEach: function() {
    App = startApp();
    TestHelper.setup(App);

    paper = make('paper', { phases: [], tasks: [] });
    topic = make('topic_with_replies', { paperId: paper.id, title: 'Hipster Ipsum Dolor' });

    $.mockjax({url: '/api/user_flows/authorization', status: 204});
    $.mockjax({url: '/api/admin/journals/authorization', status: 204});
    $.mockjax({url: /\/api\/papers\/\d+\/manuscript_manager/, status: 204});
    $.mockjax({url: /\/api\/journals/, type: 'GET', status: 200, responseText: { journals: [] }});

    TestHelper.handleFind(paper);
    TestHelper.handleFindAll('discussion-topic', 1);

    const restless = App.__container__.lookup('service:restless');
    restless['delete'] = function() {
      return Ember.RSVP.resolve({});
    };
  }
});

test('can see a list of topics', function(assert) {
  Ember.run(function() {
    visit('/papers/' + paper.id + '/workflow/discussions/');

    andThen(function() {
      let topic = find('.discussions-index-topic:first');
      assert.ok(topic.length, 'Topic is found: ' + topic.text());
    });
  });
});

test('can see a topic and a reply', function(assert) {
  Ember.run(function() {
    TestHelper.handleFind(topic);
    visit('/papers/' + paper.id + '/workflow/discussions/' + topic.get('id'));

    andThen(function() {
      let titleText = find('.discussions-show-title input').val();
      let replyText = find('.comment-body:first').text();

      assert.equal(titleText, 'Hipster Ipsum Dolor', 'Topic title is found: ' + titleText);
      assert.ok(replyText, 'Reply is found: ' + replyText);
    });
  });
});
