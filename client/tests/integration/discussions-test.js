import Ember from 'ember';
import { module, test } from 'qunit';
import startApp from 'tahi/tests/helpers/start-app';
import { make } from 'ember-data-factory-guy';
import Factory from '../helpers/factory';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';

const { mockCreate, mockFind } = TestHelper;

let App = null;
let paper, topic;

module('Integration: Discussions', {
  afterEach() {
    Ember.run(function() { TestHelper.teardown(); });
    Ember.run(App, 'destroy');
  },

  beforeEach() {
    App = startApp();
    TestHelper.setup(App);

    paper = make('paper_with_discussion', { phases: [], tasks: [] });
    topic = make(
      'topic_with_replies',
      { paperId: paper.id, title: 'Hipster Ipsum Dolor' });

    $.mockjax({
      url: '/api/at_mentionable_users',
      type: 'GET',
      status: 200,
      contentType: 'application/json',
      responseText: {
        users: [{id: 1, full_name: 'Charmander', email: 'fire@oak.edu'}]
      }
    });
    var paperResponse = paper.toJSON();
    paperResponse.id = 1;

    $.mockjax({
      url: '/api/papers/' + paperResponse.shortDoi,
      status: 200, 
      responseText: {
        paper: paperResponse
      }
    });

    $.mockjax({url: '/api/admin/journals/authorization', status: 204});
    $.mockjax({url: /\/api\/papers\/\d+\/manuscript_manager/, status: 204});
    $.mockjax({url: /\/api\/journals/, type: 'GET', status: 200, responseText: { journals: [] }});

    mockFind('paper').returns({ model: paper });
    TestHelper.mockFindAll('discussion-topic', 1);

    Factory.createPermission('Paper', paper.id, ['manage_workflow', 'start_discussion']);

    const restless = App.__container__.lookup('service:restless');
    restless['delete'] = function() {
      return Ember.RSVP.resolve({});
    };
  }
});

test('can see a list of topics', function(assert) {
  Ember.run(function() {
    mockFind('discussion-topic').returns({ model: topic });

    visit('/papers/' + paper.id + '/workflow/discussions/');

    andThen(function() {
      const firstTopic = find('.discussions-index-topic:first');
      assert.ok(firstTopic.length, 'Topic is found: ' + firstTopic.text());
    });
  });
});

test('cannot create discussion without title', function(assert) {
  Ember.run(function() {
    mockFind('discussion-topic').returns({ model: topic });
    visit('/papers/' + paper.id + '/workflow/discussions/new');
    click('#create-topic-button');

    andThen(function() {
      const titleFieldContainer = find('#topic-title-field').parent();
      assert.ok(titleFieldContainer.hasClass('error'), 'Error is displayed');
    });
  });
});

test('can see a non-editable topic with view permissions', function(assert) {
  Factory.createPermission('DiscussionTopic', 1, ['view']);

  Ember.run(function() {
    mockFind('discussion-topic').returns({ model: topic });
    visit('/papers/' + paper.id + '/workflow/discussions/' + topic.get('id'));

    andThen(function() {
      const titleText = find('.discussions-show-title').text().trim();
      assert.equal(titleText, 'Hipster Ipsum Dolor', 'Topic title is found: ' + titleText);
    });
  });
});

test('can reply to a topic with view permissions', function(assert) {
  const replyText = 'test';
  const topicScreen = '/papers/' + paper.id + '/workflow/discussions/' + topic.get('id');

  Factory.createPermission('DiscussionTopic', 1, ['view']);
  mockFind('discussion-topic').returns({ model: topic });
  mockCreate('discussion-reply').returns({ body: replyText });

  visit(topicScreen).then(function() {
    triggerEvent(find('.new-comment-field'), 'focus').then(function() {
      find('.new-comment-field').val(replyText).trigger('change');
      return triggerEvent(find('.new-comment-submit-button'), 'click');
    });
  });

  andThen(function() {
    const text = $('.message-comment:last .comment-body').text();
    assert.equal(text, replyText, 'Reply is found');
  });
});

test('reply is cached if unsaved', function(assert) {
  const topicScreen = '/papers/' + paper.id + '/workflow/discussions/' + topic.get('id');
  const replyText = 'test';

  Factory.createPermission('DiscussionTopic', 1, ['view']);
  mockFind('discussion-topic').returns({ model: topic });

  visit(topicScreen).then(function() {
    find('.new-comment-field').val(replyText).trigger('keyup');
    find('.sheet-toolbar-button').click();
  });

  visit(topicScreen);

  andThen(function() {
    assert.equal(find('.new-comment-field').val(), replyText, 'Text cached');
  });
});

test('comment body line returns converted to break tags', function(assert) {
  Factory.createPermission('DiscussionTopic', 1, ['view']);

  Ember.run(function() {
    mockFind('discussion-topic').returns({ model: topic });
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
    mockFind('discussion-topic').returns({ model: topic });
    visit('/papers/' + paper.id + '/workflow/discussions/' + topic.get('id'));

    andThen(function() {
      const titleText = find('.discussions-show-title input').val();
      assert.equal(titleText, 'Hipster Ipsum Dolor', 'Topic title is found: ' + titleText);
    });
  });
});

test('cannot persist empty title', function(assert) {
  Factory.createPermission('DiscussionTopic', 1, ['view', 'edit']);

  Ember.run(function() {
    mockFind('discussion-topic').returns({ model: topic });
    visit('/papers/' + paper.id + '/workflow/discussions/' + topic.get('id'));

    andThen(function() {
      const titleField = find('.discussions-show-title input');
      const titleFieldContainer = find('.discussions-show-title');

      titleField.focus();
      titleField.val('');
      titleField.blur();

      triggerEvent(titleField, 'blur').then(()=> {
        assert.ok(titleFieldContainer.hasClass('error'), 'Error is displayed on title');
      });
    });
  });
});
