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
import { make, manualSetup } from 'ember-data-factory-guy';
import { moment } from 'tahi/lib/aperta-moment';

moduleForComponent('invitation-header', 'Integration | Component | invitation header', {
  integration: true,

  beforeEach: function () {
    manualSetup(this.container);
  },

  setupAndRender(invitationOptions) {
    this.set('invitation', make('invitation', invitationOptions));
    this.render(hbs`{{invitation-header invitation=invitation}}`);
  }
});

test('it displays the invitation role', function(assert) {
  const inviteeRole = 'Pokémon Professor';
  this.setupAndRender({inviteeRole});
  assert.textPresent('.invitation-type', inviteeRole);
});

test("it displays the invitation's paper's title", function(assert) {
  const title = 'Bulbasaur Stuff';
  this.setupAndRender({title});
  assert.textPresent('.invitation-paper-title', title);
});

test("it displays the invitation's paper's title", function(assert) {
  const paperType = 'Pokémon Research Article';
  this.setupAndRender({paperType});
  assert.textPresent('.invitation-paper-type',paperType);
});

test("it displays the invitation's send date", function(assert) {
  const createdAt = moment('1997-08-29');
  this.setupAndRender({createdAt});
  assert.textPresent('.date', 'August 29, 1997');
});
