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
import { moduleForModel, test } from 'ember-qunit';
import FactoryGuy from 'ember-data-factory-guy';
import sinon from 'sinon';
import startApp from 'tahi/tests/helpers/start-app';
import * as TestHelper from 'ember-data-factory-guy';

var app;
moduleForModel('decision', 'Unit | Model | decision', {
  integration: true,
  afterEach: function() {
    Ember.run(function() {
      return TestHelper.mockTeardown();
    });
    return Ember.run(app, 'destroy');
  },
  beforeEach: function() {
    app = startApp();
    return TestHelper.mockSetup();
  }
});


test("rescind() uses restless to touch the rescind endpoint", function(assert) {
  let fakeRestless = {
    put: sinon.stub()
  };
  fakeRestless.put.returns({ then: () => {} });

  let decision = FactoryGuy.make('decision', {
    rescindable: true
  });

  decision.set('restless', fakeRestless);

  decision.rescind();
  assert.spyCalledWith(fakeRestless.put,
    [`/api/decisions/${decision.id}/rescind`],
    'Calls restless with rescind endpoint');
});

test('revisionNumber', function(assert) {
  const [majorVersion, minorVersion] = [1, 2];
  const decision = FactoryGuy.make('decision', {
    majorVersion,
    minorVersion
  });

  assert.equal(
    decision.get('revisionNumber'),
    `${majorVersion}.${minorVersion}`
  );
});

test('terminal', function(assert) {
  assert.ok(FactoryGuy.make('decision', { verdict: 'accept' }).get('terminal'));
  assert.ok(FactoryGuy.make('decision', { verdict: 'reject' }).get('terminal'));
  assert.notOk(FactoryGuy.make('decision', { verdict: 'major_revision' }).get('terminal'));
  assert.notOk(FactoryGuy.make('decision', { verdict: 'minor_revision' }).get('terminal'));
});
