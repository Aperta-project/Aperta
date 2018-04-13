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

import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent(
  'card-history/table',
  'Integration | Component | card history | table',
  {
    integration: true
  }
);

let template = hbs`{{card-history/table cardVersions=cardVersions}}`;

test('it renders sorted cardVersions ', function(assert) {
  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });
  this.set('cardVersions', [
    {
      publishedAt: moment().subtract(20, 'days').toDate(),
      historyEntry: 'Oldest',
      isPublished: true
    },
    {
      publishedAt: moment().toDate(),
      historyEntry: 'Newer',
      isPublished: true
    },
    { publishedAt: null, historyEntry: 'Newest', isPublished: false }
  ]);

  this.render(template);

  assert.arrayContainsExactly(
    this.$('.history-entry').map((i, e) => e.innerText).get(),
    ['Newest', 'Newer', 'Oldest']
  );
});

test('rendering for an individual version', function(assert) {
  // Set any properties with this.set('myProperty', 'value');
  // Handle any actions with this.on('myAction', function(val) { ... });
  this.set('cardVersions', [
    {
      publishedAt: moment().subtract(20, 'days').toDate(),
      historyEntry: 'Oldest',
      publishedBy: 'Steve'
    }
  ]);

  this.render(template);
  assert.textPresent(
    '.history-entry',
    'Oldest',
    'displays the given history entry'
  );
  assert.textPresent('.published-by', 'Steve', 'displays publishedBy if given');

  this.set('cardVersions', [
    {
      publishedAt: null,
      publishedBy: null,
      historyEntry: null
    }
  ]);
  assert.textPresent(
    '.history-entry',
    'Current Unpublished Version',
    'displays placeholder for the latest version'
  );
});
