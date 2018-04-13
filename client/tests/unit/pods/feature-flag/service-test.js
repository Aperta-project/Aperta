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

import { moduleFor, test } from 'ember-qunit';
import { make, manualSetup }  from 'ember-data-factory-guy';

moduleFor('service:feature-flag', 'Unit | Service | Feature flag', {
  needs: ['model:feature-flag', 'service:store'],
  beforeEach() {
    manualSetup(this.container);
  }
});

test('value returns the value of the flag', function(assert) {
  make('feature-flag', {id: 1, name: 'ACTIVE_FLAG', active: true});
  make('feature-flag', {id: 2, name: 'INACTIVE_FLAG', active: false});

  const value1 = this.subject().value('ACTIVE_FLAG');
  const value2 = this.subject().value('INACTIVE_FLAG');

  assert.ok(value1, 'the flag is active');
  assert.notOk(value2, 'the flag is inactive');
});
