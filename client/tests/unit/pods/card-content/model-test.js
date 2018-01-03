import Ember from 'ember';
import { moduleForModel, test } from 'ember-qunit';
import { make } from 'ember-data-factory-guy';
import startApp from 'tahi/tests/helpers/start-app';
import * as TestHelper from 'ember-data-factory-guy';

var app;
moduleForModel('card-content', 'Unit | Model | Card Content', {
  integration: true,
  afterEach: function() {
    Ember.run(function() {
      return TestHelper.mockTeardown();
    });
    return Ember.run(app, 'destroy');
  },
  beforeEach: function() {
    app = startApp();
    return TestHelper.mockSetup();
  }
});

test('answerForOwner returns null if not answerable', function(assert) {
  let owner = null;
  let repetition = null;
  let cardContent = make('card-content', { valueType: null });

  assert.equal(cardContent.answerForOwner(owner, repetition), null);
});

test('answerForOwner returns answer that does not have repetition', function(assert) {
  let repetition = null;
  let cardContent = make('card-content', { repetition: repetition });

  let task = make('custom-card-task');
  task.set('cardVersion.contentRoot', cardContent);
  let answer = make('answer', { owner: task, cardContent: cardContent, repetition: repetition } );

  assert.equal(cardContent.answerForOwner(task, repetition), answer);
});

test('answerForOwner returns answer that belongs to a repetition', function(assert) {
  let cardContent = make('card-content');
  let task = make('custom-card-task');
  task.set('cardVersion.contentRoot', cardContent);
  let repetition = make('repetition', { task: task, cardContent: cardContent });
  let answer = make('answer', { owner: task, cardContent: cardContent, repetition: repetition } );

  assert.equal(cardContent.answerForOwner(task, repetition), answer);
});

test('answerForOwner creates an unsaved default answer that is associated to a repetition', function(assert) {
  let cardContent = make('card-content');
  let task = make('custom-card-task');
  task.set('cardVersion.contentRoot', cardContent);
  let repetition = make('repetition', { task: task, cardContent: cardContent });

  Ember.run(() => {
    let answer = cardContent.answerForOwner(task, repetition);
    assert.ok(answer.get('isNew'));
    assert.equal(answer.get('repetition'), repetition);
  });
});

test('parsedDefaultAnswerValue returns the answer string if the valueType is text', function (assert) {
  let cardContent = make('card-content');
  Ember.run(() => {
    cardContent.set('defaultAnswerValue', 'TEXT ANSWER');
    cardContent.set('valueType', 'text');

    assert.equal(cardContent.parsedDefaultAnswerValue(), 'TEXT ANSWER');
  });
});

test('parsedDefaultAnswerValue returns the answer string if the valueType is html', function (assert) {
  let cardContent = make('card-content');
  Ember.run(() => {
    cardContent.set('defaultAnswerValue', 'TEXT ANSWER');
    cardContent.set('valueType', 'html');

    assert.equal(cardContent.parsedDefaultAnswerValue(), 'TEXT ANSWER');
  });
});

test('parsedDefaultAnswerValue returns the answer boolean if the valuetype is different from text or html', function (assert) {
  let cardContent = make('card-content');
  Ember.run(() => {
    cardContent.set('defaultAnswerValue', 'true');
    cardContent.set('valueType', 'boolean');

    assert.equal(cardContent.parsedDefaultAnswerValue(), true);
  });
});
