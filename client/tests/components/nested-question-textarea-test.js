import { test, moduleForComponent } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make } from 'ember-data-factory-guy';
import registerCustomAssertions from '../helpers/custom-assertions';
import Ember from 'ember';
import wait from 'ember-test-helpers/wait';

moduleForComponent('nested-question-textarea', 'Integration | Component | nested question textarea', {
  integration: true,
  beforeEach() {
    registerCustomAssertions();
    manualSetup(this.container);
    this.registry.register('pusher:main', Ember.Object.extend({socketId: 'foo'}));

    this.getAnswers = function() {
      return this.container.lookup('service:store').peekAll('answer');
    };
  },

  afterEach() {
    $.mockjax.clear();
  }
});

let template = hbs`{{nested-question-textarea ident="foo" owner=task}}`;

test('saves on input events', function(assert) {
  let task =  make('ad-hoc-task');
  make('card-content', { ident: 'foo' });
  this.set('task', task);

  this.render(template);

  $.mockjax({url: '/api/answers', type: 'POST', status: 204, responseText: '{}'});
  this.$('textarea').val('new comment').trigger('input');

  return wait().then(() => {
    assert.mockjaxRequestMade('/api/answers', 'POST', 'it saves the new answer on input');
  });
});

test('does not save on change events', function(assert) {
  let task =  make('ad-hoc-task');
  make('card-content', { ident: 'foo' });
  this.set('task', task);

  this.render(template);

  $.mockjax({url: '/api/answers', type: 'POST', status: 204, responseText: '{}'});
  this.$('textarea').val('new comment').trigger('change');

  return wait().then(() => {
    assert.mockjaxRequestNotMade('/api/answers', 'POST', 'it saves the new answer on input');
  });
});
