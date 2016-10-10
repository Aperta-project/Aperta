import Ember from 'ember';
import { test, moduleForComponent } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make } from 'ember-data-factory-guy';
import registerCustomAssertions from '../helpers/custom-assertions';
import wait from 'ember-test-helpers/wait';

/*
 * This set of tests are more like unit tests for the nested-question component,
 * but due to the number of collaborators involved and how important it is to get
 * the actual behavior of those collaborators right (nested-question's answerForOwner, etc)
 * and how much of a pain it would be to do a `needs: [foo:bar]` statement for those things,
 * I've made this a component integration test instead.
 * */

moduleForComponent('nested-question', 'Integration | Component | nested question', {
  integration: true,
  beforeEach() {
    registerCustomAssertions();
    manualSetup(this.container);
  }
});

let template = hbs`
{{#nested-question owner=task decision=decision ident="foo" as |q|}}
  <span class="question-text">{{q.question.text}}</span>
  {{input class="answer-value" value=q.answer.value}}
  <button {{action q.save}}>Save</button>
{{/nested-question}}
`;

test('finds its question by ident and owner', function(assert) {
  // question is null if owner is null
});

test('finds its answer by ident, owner, and decision', function(assert) {
  // answer is null if owner is null
  // finds answer based on decision
});

test('save action saves the answer', function(assert) {
});

test('saving is a no-op if the owner is new', function(assert) {
});


test('saving a blank answer actually destroys it', function(assert) {
  // assert that there's a different answer in the template than the
  // original one
});
