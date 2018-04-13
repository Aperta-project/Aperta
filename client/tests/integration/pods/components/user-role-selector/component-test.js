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
import hbs from 'htmlbars-inline-precompile';

moduleForComponent(
  'user-role-selector',
  'Integration | Component | user role selector',
  {
    integration: true,
    beforeEach: function() {
      this.set('journalRoles', () => {});
      this.set('userJournalRoles', []);
      this.set('actionStub', []);
    }
  });

var template = hbs`{{user-role-selector
                      journalRoles=journalRoles
                      selected=actionStub
                      removed=actionStub
                      }}`;

test('displays role selector', function(assert) {
  this.render(template);
  assert.elementFound('.user-role-selector', 'role selector is displayed');
});

test('displays assign role button', function(assert) {
  this.render(template);
  assert.elementFound('.assign-role-button', 'assign role button is displayed');
});
