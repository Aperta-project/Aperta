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
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup }  from 'ember-data-factory-guy';
import hbs from 'htmlbars-inline-precompile';
import customAssertions from 'tahi/tests/helpers/custom-assertions';

moduleForComponent(
  'decision-bar',
  'Integration | Component | decision bar', {
    integration: true,
    beforeEach() {
      customAssertions();
      manualSetup(this.container);
    }
  }
);

test('shows the decision verdict when closed', function(assert) {
  let decision = FactoryGuy.make('decision', { verdict: 'major_revision' });
  setup(this, { decision });
  assert.textPresent(
    '.decision-bar-verdict',
    'Major Revision',
    'shows verdict');

  assert.elementNotFound('.decision-bar-letter', 'does not show letter');
});

test('shows the revision number when closed', function(assert) {
  let decision = FactoryGuy.make(
    'decision', { majorVersion: 2, minorVersion: 1 });
  setup(this, { decision });
  assert.textPresent('.decision-bar-revision-number', '2.1', 'shows revision');
});

test('shows the rescinded flag for a rescinded decision when closed',
  function(assert) {
    let decision = FactoryGuy.make('decision', {
      majorVersion: 2,
      minorVersion: 3,
      rescinded: true });

    setup(this, { decision });
    assert.textPresent(
      '.decision-bar-revision-number',
      '2.3',
      'shows revision');
    assert.textPresent(
      '.decision-bar-rescinded',
      'Rescinded',
      'shows rescinded flag');
  }
);

test('shows the decision letter when unfolded', function(assert) {
  let decision = FactoryGuy.make('decision', { letter: 'a letter' });
  setup(this, { decision, unfolded: true });
  assert.textPresent('.decision-bar-letter', 'a letter', 'shows letter');
});

test('clicking the verdict unfolds the decision', function(assert) {
  setup(this, {});
  assert.elementNotFound(
    '.decision-bar-letter',
    'is folded (letter invisible)');

  this.$('.decision-bar-bar').click();
  assert.elementFound(
    '.decision-bar-letter',
    'unfolds (letter visible)');
});

test('Author response is present if decision has one', function(assert) {
  let decision = FactoryGuy.make('decision', { authorResponse: 'nuts' });
  setup(this, { decision, unfolded: true });
  assert.textPresent(
    '.decision-bar-author-response',
    'nuts',
    'author response present');
});


function setup(context, {decision, unfolded}) {
  decision = decision || FactoryGuy.make('decision');

  context.set('decision', decision);
  context.set('folded', !unfolded);

  let template = hbs`{{decision-bar decision=decision
                                    folded=folded}}`;

  context.render(template);
}
