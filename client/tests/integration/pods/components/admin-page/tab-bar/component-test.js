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

import {moduleForComponent, test} from 'ember-qunit';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup } from 'ember-data-factory-guy';
import FakeCanService from 'tahi/tests/helpers/fake-can-service';
import hbs from 'htmlbars-inline-precompile';

let journal1, journal2, journals;

moduleForComponent('admin-page/card-thumbnail', 'Integration | Component | admin page | tab bar', {
  integration: true,

  beforeEach() {
    manualSetup(this.container);
    journal1 = FactoryGuy.make('journal');
    journal2 = FactoryGuy.make('journal');

    journals = [journal1 , journal2];
  },

  afterEach() {
    $.mockjax.clear();
  }
});

test('no specific journal given, not all journals administratable', function(assert) {
  this.set('journals', journals);
  const can = FakeCanService.create();
  this.register('service:can', can.asService());
  this.render(hbs`{{admin-page/tab-bar journals=journals}}`);

  assert.elementNotFound('.admin-nav-workflows', 'admin-nav-workflows');
  assert.elementNotFound('.admin-nav-settings', 'admin-nav-settings');
  assert.elementFound('.admin-nav-users', 'admin-nav-workflows');
});

test('no specific journal given, all journals administratable', function(assert) {
  this.set('journals', journals);
  const can = FakeCanService.create();
  can.allowPermission('administer', '*');
  this.register('service:can', can.asService());

  this.render(hbs`{{admin-page/tab-bar journals=journals}}`);
  assert.elementFound('.admin-nav-workflows', 'admin-nav-workflows');
  assert.elementFound('.admin-nav-settings', 'admin-nav-settings');
  assert.elementFound('.admin-nav-users', 'admin-nav-workflows');
});

test('a specific journal given which does not have administer permissions', function(assert) {
  this.set('journals', journals);
  this.set('journal', journal1);

  const can = FakeCanService.create();
  this.register('service:can', can.asService());

  this.render(hbs`{{admin-page/tab-bar journals=journals journal=journal}}`);

  assert.elementNotFound('.admin-nav-workflows', 'admin-nav-workflows');
  assert.elementNotFound('.admin-nav-settings', 'admin-nav-settings');
  assert.elementFound('.admin-nav-users', 'admin-nav-workflows');
});

test('a specific journal given which has administer permissions', function(assert) {
  this.set('journals', journals);
  this.set('journal', journal1);

  const can = FakeCanService.create();
  can.allowPermission('administer', journal1);
  this.register('service:can', can.asService());

  this.render(hbs`{{admin-page/tab-bar journals=journals journal=journal}}`);

  assert.elementFound('.admin-nav-workflows', 'admin-nav-workflows');
  assert.elementFound('.admin-nav-settings', 'admin-nav-settings');
  assert.elementFound('.admin-nav-users', 'admin-nav-workflows');
});
