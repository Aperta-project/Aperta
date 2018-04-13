/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

import {
  moduleForComponent,
  test
} from 'ember-qunit';
import { manualSetup, make } from 'ember-data-factory-guy';
import Ember from 'ember';
import hbs from 'htmlbars-inline-precompile';
import customAssertions from 'tahi/tests/helpers/custom-assertions';
import { initialize as initTruthHelpers }  from 'tahi/initializers/truth-helpers';
import sinon from 'sinon';
import FakeCanService from 'tahi/tests/helpers/fake-can-service';

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

test('rescind link, when clicked calls rescind method', function(assert) {
  let { decision } = setup(this);

  clickThroughRescind(this, assert);

  assert.spyCalled(decision.rescind, '#rescind method was called on decision');
});

test('busyWhile is called', function(assert) {
  const busyWhile = sinon.stub();
  setup(this, function({ context }) {
    context.set('busyWhile', busyWhile);
  });

  clickThroughRescind(this, assert);

  assert.spyCalled(busyWhile);
});

function setup(context, callback) {
  const paper = make('paper');
  const decision = make('decision', { paper: paper, rescindable: true });
  decision.rescind = sinon.stub().returns({ then: () => {} });
  const can = FakeCanService.create();
  can.allowPermission('rescind_decision', paper);
  context.set('decision', decision);
  context.set('isEditable', true);
  context.set('mockRestless', false);
  context.set('busyWhile', ()=>{});
  const vals = { context, decision, paper, can };
  if (callback) { callback(vals); }
  let template = hbs`{{rescind-decision decision=decision
                                        isEditable=isEditable
                                        restless=mockRestless
                                        busyWhile=(action busyWhile)}}`;
  context.register('service:can', can.asService());
  context.render(template);
  return vals;
}

function clickThroughRescind(context, assert) {
  // Ask to rescind.
  context.$('.rescind-decision-button').click();

  assert.elementFound(
    '.full-overlay-verification-confirm',
    'Confirm dialog appears');

  // Confirm request to rescind
  context.$('.full-overlay-verification-confirm').click();
}
