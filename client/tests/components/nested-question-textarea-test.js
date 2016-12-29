import { test, moduleForComponent } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make } from 'ember-data-factory-guy';
import { createQuestion } from 'tahi/tests/factories/nested-question';
import registerCustomAssertions from '../helpers/custom-assertions';
import FakeCanService from '../helpers/fake-can-service';
import Ember from 'ember';
import wait from 'ember-test-helpers/wait';

moduleForComponent('nested-question-textarea', 'Integration | Component | nested question textarea', {
  integration: true,
  beforeEach() {
    registerCustomAssertions();
    manualSetup(this.container);
    this.registry.register('pusher:main', Ember.Object.extend({socketId: 'foo'}));
    this.registry.register('service:can', FakeCanService);

    this.getAnswers = function() {
      return this.container.lookup('service:store').peekAll('nested-question-answer');
    };
  },

  afterEach() {
    $.mockjax.clear();
  }
});

test('saves on input events', function(assert) {
  let task =  make('ad-hoc-task');
  let fake = this.container.lookup('service:can');
  fake.allowPermission('edit', task);
  createQuestion(task, 'foo');
  this.set('task', task);

  this.render(hbs`
    {{nested-question-textarea ident="foo" owner=task}}
  `);

  $.mockjax({url: '/api/nested_questions/1/answers', type: 'POST', status: 204, responseText: '{}'});
  this.$('textarea').val('new comment').trigger('input');

  return wait().then(() => {
    assert.mockjaxRequestMade('/api/nested_questions/1/answers', 'POST', 'it saves the new answer on input');
  });
});


test('Does not save on input events in IE', function(assert) {
  const FakeBrowserDetectorService = Ember.Object.create({
    isIE11OrLess: false
  });
  this.registry.register('service:browser-detector', FakeBrowserDetectorService, {instantiate: false});

  let task =  make('ad-hoc-task');
  let fake = this.container.lookup('service:can');
  fake.allowPermission('edit', task);
  createQuestion(task, 'foo');
  this.set('task', task);

  this.render(hbs`
    {{nested-question-textarea ident="foo" owner=task}}
  `);

  $.mockjax({url: '/api/nested_questions/1/answers', type: 'POST', status: 204, responseText: '{}'});
  this.$('textarea').val('new comment').trigger('input');

  return wait().then(() => {
    assert.mockjaxRequestNotMade('/api/nested_questions/1/answers', 'POST', 'it saves the new answer on input');
  });
});
