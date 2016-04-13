import {
  moduleForComponent,
  test
} from 'ember-qunit';

import Ember from 'ember';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('nested-question-check', 'Component: nested-question-check', {
  integration: true
});

test('it renders', function(assert) {
  let fakeQuestion = Ember.Object.create({
    ident: 'foo',
    additionalData: [{}],
    text: 'Test Question',
    answerForOwner: function(){ return Ember.Object.create(); },
    save() { return null; },
  });

  this.set('task', Ember.Object.create({
    findQuestion: function(){ return fakeQuestion; }
  }));

  this.render(hbs`
    {{nested-question-check ident="foo" owner=task}}
  `);

  assert.equal(this.$('label:contains("Test Question")').length, 1);
});

test('when providing a block it renders additional data when initializing with a value as already checked', function(assert) {
  let fakeQuestion = Ember.Object.create({
    ident: 'foo',
    additionalData: [{}],
    text: 'Test Question',
    answerForOwner: function(){ return Ember.Object.create({value: true}); },
    save() { return null; },
  });

  this.set('task', Ember.Object.create({
    findQuestion: function(){ return fakeQuestion; }
  }));

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
  let fakeQuestion = Ember.Object.create({
    ident: 'foo',
    additionalData: [{}],
    text: 'Test Question',
    answerForOwner: function(){ return Ember.Object.create({value: true}); },
    save() { return null; },
  });

  this.set('task', Ember.Object.create({
    findQuestion: function(){ return fakeQuestion; }
  }));

  this.render(hbs`
    {{#nested-question-check ident="foo" owner=task displayQuestionText=false as |selection|}}
      {{#if selection.yieldingForText }}
        <label class="custom-question">Custom question</label>
      {{/if}}
    {{/nested-question-check}}
  `);
  assert.equal(this.$('label.custom-question:contains("Custom question")').length, 1);
});
