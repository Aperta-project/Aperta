import {
  moduleForComponent,
  test
} from 'ember-qunit';
import { manualSetup, make } from 'ember-data-factory-guy';
import Ember from 'ember';
import hbs from 'htmlbars-inline-precompile';
import customAssertions from '../helpers/custom-assertions';
import { initialize as initTruthHelpers }  from 'tahi/initializers/truth-helpers';
import sinon from 'sinon';
import FakeCanService from '../helpers/fake-can-service';

moduleForComponent(
  'rescind-decision',
  'Integration | Component | rescind decision', {
    integration: true,
    beforeEach() {
      initTruthHelpers();
      customAssertions();
      manualSetup(this.container);
    }
  });

test('is hidden if there is no decision', function(assert) {
  setup(this, function({ context }) {
    context.set('decision', null);
  });
  assert.elementFound('.rescind-decision.hidden', 'the bar is hidden');
});

test('is hidden if the decision is a draft', function(assert) {
  setup(this, function({ decision }) {
    decision.draft = true;
  });
  assert.elementFound('.rescind-decision.hidden', 'the bar is hidden');
});

test('is hidden if the decision is rescinded', function(assert) {
  setup(this, function({ decision }) {
    decision.rescinded = true;
  });
  assert.elementFound('.rescind-decision.hidden', 'the bar is hidden');
});

test('button is missing if the decision is not rescindable', function(assert) {
  setup(this, function({ decision }) {
    decision.rescindable = false;
  });
  assert.elementNotFound('button.rescind-decision-button', 'the button is hidden');
});

test('button is present if the decision is rescindable', function(assert) {
  setup(this);
  assert.elementFound('button.rescind-decision-button', 'the button is present');
});

test('button is missing if the user does not have permissions', function(assert) {
  setup(this, function({ can }) {
    can.rejectPermission('rescind_decision');
  });
  assert.elementNotFound('button.rescind-decision-button', 'the button is hidden');
});

test('rescind link is disabled if not editable', function(assert) {
  setup(this, function({context}) {
    context.set('isEditable', false);
  });
  assert.elementFound('.rescind-decision-button:disabled', 'the button is disabled');
});

test('rescind link, when clicked, calls restless to rescind', function(assert) {
  let { decision } = setup(this, function({ decision }) {
    decision.rescind = sinon.stub();
    decision.rescind.returns({ then: () => {} });
  });

  Ember.run(() => {
    // Ask to rescind.
    this.$('.rescind-decision-button').click();

    // Confirm request to rescind
    assert.elementFound(
      '.full-overlay-verification-confirm',
      'Confirm dialog appears');
    this.$('.full-overlay-verification-confirm').click();
  });

  assert.spyCalled(decision.rescind, 'decision was rescinded');
});

function setup(context, callback) {
  const paper = make('paper');
  const decision = make('decision', { paper: paper, rescindable: true });
  const can = FakeCanService.create();
  can.allowPermission('rescind_decision', paper);
  context.set('decision', decision);
  context.set('isEditable', true);
  context.set('mockRestless', false);
  const vals = { context, decision, paper, can };
  if (callback) { callback(vals); }

  let template = hbs`{{rescind-decision decision=decision
                                        isEditable=isEditable
                                        restless=mockRestless}}`;
  context.register('service:can', can.asService());
  context.render(template);
  return vals;
}
