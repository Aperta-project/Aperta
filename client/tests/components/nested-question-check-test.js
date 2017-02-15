import {
  moduleForComponent,
  test
} from 'ember-qunit';
import { manualSetup, make } from 'ember-data-factory-guy';
import { createAnswer } from 'tahi/tests/factories/answer';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent('nested-question-check', 'Integration | Component | nested question check', {
  integration: true,
  beforeEach() {
    manualSetup(this.container);
  }
});

test('it renders as long as the card content with the given ident is in the store', function(assert) {
  make('card-content', {
    ident: 'foo',
    additionalData: [{}],
    text: 'Test Question'
  });

  this.render(hbs`
    {{nested-question-check ident="foo"}}
  `);

  assert.equal(this.$('label:contains("Test Question")').length, 1);
});

test('when providing a block it renders additional data when initializing with a value as already checked', function(assert) {
  make('card-content', {
    ident: 'foo',
    additionalData: [{}],
    text: 'Test Question'
  });

  let task = make('ad-hoc-task');
  createAnswer(task, 'foo', { value: true });

  this.set('task', task);

  this.render(hbs`
    {{#nested-question-check ident="foo" owner=task as |selection|}}
      {{#if selection.yieldingForAdditionalData }}
        {{#if selection.checked}}
          <div class="successfully-initialized-as-checked" />
        {{/if}}
      {{/if}}
    {{/nested-question-check}}
  `);

  assert.equal(this.$('.successfully-initialized-as-checked').length, 1);
});

test('when providing a block it renders the text provided when it yieldsForText and displayQuestionText=false', function(assert) {
  make('card-content', {
    ident: 'foo',
    additionalData: [{}],
    text: 'Test Question'
  });

  let task = make('ad-hoc-task');
  createAnswer(task, 'foo', { value: true });

  this.set('task', task);
  this.render(hbs`
    {{#nested-question-check ident="foo" owner=task displayQuestionText=false as |selection|}}
      {{#if selection.yieldingForText }}
        <label class="custom-question">Custom question</label>
      {{/if}}
    {{/nested-question-check}}
  `);
  assert.equal(this.$('label.custom-question:contains("Custom question")').length, 1);
});
