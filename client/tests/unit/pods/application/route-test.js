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
import sinon from 'sinon';
import Ember from 'ember';

moduleFor('route:application', 'Unit | Route | application', {
  integration: true
});

test('signOut ends the user\'s full story session', function(assert) {
  const clearSessionSpy = sinon.spy();
  const fullStoryMock = Ember.Service.extend({
    clearSession: clearSessionSpy
  });
  this.container.registry.register('service:full-story', fullStoryMock);
  const route = this.subject();
  const stub = sinon.stub(route, 'assignWindowLocation');
  route.send('signOut');
  assert.spyCalled(clearSessionSpy);
  stub.restore();
});

test('signOut changes the window.location', function(assert) {
  const route = this.subject();
  const mock = sinon.mock(route);
  const expectation = mock.expects('assignWindowLocation');
  route.send('signOut');
  assert.spyCalledWith(expectation, ['/users/sign_out'], 'assignWindowLocation() should have been called');
  mock.restore();
});
