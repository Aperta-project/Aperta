import Ember from 'ember';
import { module, test } from 'qunit';
import startApp from 'tahi/tests/helpers/start-app';
import { make } from 'ember-data-factory-guy';
import Factory from '../helpers/factory';
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

    Factory.createPermission('Paper', paper.id, ['manage_workflow']);

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
      const topic = find('.discussions-index-topic:first');
      assert.ok(topic.length, 'Topic is found: ' + topic.text());
    });
  });
});

test('can see a non-editable topic with view permissions', function(assert) {
  Factory.createPermission('DiscussionTopic', 1, ['view']);

  Ember.run(function() {
    TestHelper.handleFind(topic);
    visit('/papers/' + paper.id + '/workflow/discussions/' + topic.get('id'));

    andThen(function() {
      const titleText = find('.discussions-show-title').text().trim();
      assert.equal(titleText, 'Hipster Ipsum Dolor', 'Topic title is found: ' + titleText);
    });
  });
});

test('can reply to a topic with view permissions', function(assert) {
  Factory.createPermission('DiscussionTopic', 1, ['view']);

  Ember.run(function() {
    TestHelper.handleFind(topic);
    visit('/papers/' + paper.id + '/workflow/discussions/' + topic.get('id'));

    andThen(function() {
      const replyText = find('.comment-body:first').text();
      assert.ok(replyText, 'Reply is found: ' + replyText);
    });
  });
});

test('comment body line returns converted to break tags', function(assert) {
  Factory.createPermission('DiscussionTopic', 1, ['view']);

  Ember.run(function() {
    TestHelper.handleFind(topic);
    visit('/papers/' + paper.id + '/workflow/discussions/' + topic.get('id'));

    andThen(function() {
      const replyText = find('.comment-body:first').html();
      assert.equal(replyText, 'hey<br>how are you?', 'break tags found');
    });
  });
});


test('can see an editable topic with edit permissions', function(assert) {
  Factory.createPermission('DiscussionTopic', 1, ['view', 'edit']);

  Ember.run(function() {
    TestHelper.handleFind(topic);
    visit('/papers/' + paper.id + '/workflow/discussions/' + topic.get('id'));

    andThen(function() {
      const titleText = find('.discussions-show-title input').val();
      assert.equal(titleText, 'Hipster Ipsum Dolor', 'Topic title is found: ' + titleText);
    });
  });
});
