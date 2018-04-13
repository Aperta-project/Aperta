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

import Ember from 'ember';
import { module, test } from 'qunit';
import startApp from 'tahi/tests/helpers/start-app';
import moduleForAcceptance from 'tahi/tests/helpers/module-for-acceptance';
import setupMockServer from 'tahi/tests/helpers/mock-server';
import Factory from 'tahi/tests/helpers/factory';
import { make } from 'ember-data-factory-guy';
import * as TestHelper from 'ember-data-factory-guy';

moduleForAcceptance('Integration: orcid connect permissions', {
  beforeEach: function() {
    let journal = make('journal');
    TestHelper.mockFindAll('journal').returns({models: [journal]});
    TestHelper.mockFindRecord('journal').returns({model: journal});
  }
});

test('user without permission sees contact message', function(assert) {
  Factory.createPermission(
    'User',
    1,
    ['view']);
  Factory.createPermission(
    'Journal',
    1,
    ['']);

  visit('/profile');

  andThen(function() {
    assert.ok(find('.staff-remove-orcid'));
    assert.ok(!find('.remove-orcid').length);
  });
});

test('user with permission sees remove button', function(assert) {
  Factory.createPermission(
    'User',
    1,
    ['view']);
  Factory.createPermission(
    'Journal',
    1,
    ['remove_orcid']);

  visit('/profile');

  andThen(function() {
    assert.ok(!find('.staff-remove-orcid').length);
    assert.ok(find('.remove-orcid'));
  });
});
