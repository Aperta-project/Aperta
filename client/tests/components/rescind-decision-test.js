import {
  moduleForComponent,
  test
} from 'ember-qunit';
import FactoryGuy from 'ember-data-factory-guy';
import Ember from 'ember';
import hbs from 'htmlbars-inline-precompile';
import customAssertions from '../helpers/custom-assertions';
import { initialize as initTruthHelpers }  from 'tahi/initializers/truth-helpers';
import sinon from 'sinon';
import startApp from '../helpers/start-app';
import TestHelper from 'ember-data-factory-guy/factory-guy-test-helper';
import FakeCanService from '../helpers/fake-can-service';

var app;

moduleForComponent(
  'rescind-decision',
  'Integration | Component | rescind decision', {
    integration: true,
    beforeEach() {
      initTruthHelpers();
      customAssertions();
      FactoryGuy.setStore(this.container.lookup('store:main'));
      // Mock out pusher
      this.container.register('pusher:main', Ember.Object.extend({socketId: 'foo'}));
      app = startApp();
      return TestHelper.setup(app);
    },
    afterEach: function() {
      Ember.run(function() {
        return TestHelper.teardown();
      });
      return Ember.run(app, 'destroy');
    }
  });

test('is hidden if there is no decision', function(assert) {
  setup(this, { decision: null });
  assert.elementFound('.rescind-decision.hidden', 'the bar is hidden');
});

test('is hidden if the decision is a draft', function(assert) {
  let paper = FactoryGuy.make('paper');
  let decision = FactoryGuy.make('decision', { paper, draft: true });
  setup(this, { decision });
  assert.elementFound('.rescind-decision.hidden', 'the bar is hidden');
});

test('is hidden if the decision is rescinded', function(assert) {
  let paper = FactoryGuy.make('paper');
  let decision = FactoryGuy.make('decision', { paper, rescinded: true });
  setup(this, { decision });
  assert.elementFound('.rescind-decision.hidden', 'the bar is hidden');
});

test('button is missing if the decision is not rescindable', function(assert) {
  let paper = FactoryGuy.make('paper');
  let decision = FactoryGuy.make('decision', { paper, rescindable: false });
  setup(this, { decision });
  assert.elementNotFound('button.rescind-decision-button', 'the button is hidden');
});

test('button is present if the decision is rescindable', function(assert) {
  let paper = FactoryGuy.make('paper');
  let decision = FactoryGuy.make('decision', { paper, completed: true, rescindable: true  });
  let can = FakeCanService.create();
  can.allowPermission('rescind_decision', paper);
  setup(this, { decision, can });
  assert.elementFound('button.rescind-decision-button', 'the button is present');
});

test('button is missing if the user does not have permissions', function(assert) {
  let paper = FactoryGuy.make('paper');
  let decision = FactoryGuy.make('decision', { paper, rescindable: true });
  let can = FakeCanService.create();
  can.rejectPermission('rescind_decision', paper);
  setup(this, { decision, isEditable: true, can });
  assert.elementNotFound('button.rescind-decision-button', 'the button is hidden');
});

test('rescind link is disabled if not editable', function(assert) {
  let paper = FactoryGuy.make('paper');
  let decision = FactoryGuy.make('decision', { paper, completed: true, rescindable : true });
  let can = FakeCanService.create();
  can.allowPermission('rescind_decision', paper);
  setup(this, { decision, isEditable: false, can });
  assert.elementFound('.rescind-decision-button:disabled', 'the button is disabled');
});

test('rescind link, when clicked, calls restless to rescind', function(assert) {
  let paper = FactoryGuy.make('paper');
  let decision = FactoryGuy.make('decision', { paper, rescindable: true });
  decision.rescind = sinon.stub();
  decision.rescind.returns({ then: () => {} });
  let can = FakeCanService.create();
  can.allowPermission('rescind_decision', paper);
  setup(this, { decision, can });

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

function setup(context, {decision, isEditable, mockRestless, can}) {
  isEditable = (isEditable === false ? false : true); // default true, please

  context.set('decision', decision);
  context.set('isEditable', isEditable);
  context.set('mockRestless', mockRestless);
  context.set('can', can || FakeCanService.create());

  let template = hbs`{{rescind-decision decision=decision
                                        isEditable=isEditable
                                        restless=mockRestless
                                        can=can}}`;

  context.render(template);
}
