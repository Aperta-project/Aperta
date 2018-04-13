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

import { test, moduleFor } from 'ember-qunit';

moduleFor('service:bugsnag', 'Unit | Service | Bugsnag', {
  needs: [],

  beforeEach() {
    this.service = this.subject();
  }
});

function withBugsnag(test) {
  const notifyExceptionSpy = sinon.spy();
  const bugsnag = window.Bugsnag;
  window.Bugsnag = {
    notifyException: notifyExceptionSpy
  };
  test.call(this, notifyExceptionSpy);
  window.Bugsnag = bugsnag;
}

function withoutBugsnag(test) {
  const bugsnag = window.Bugsnag;
  delete window.Bugsnag;
  test.call();
  window.Bugsnag = bugsnag;
}

test('notifyException() should work without Bugsnag', function(assert) {
  withoutBugsnag(() => {
    this.service.notifyException(new Error(), 'Tis but a flash wound');
    assert.ok('things dont blow up');
  });
});

test('notifyException() should work with Bugsnag', function(assert) {
  withBugsnag((notifyExceptionSpy) => {
    this.service.notifyException(new Error(), 'We are the knights who assert Ni!');
    assert.spyCalled(notifyExceptionSpy);
  });
});
