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
import HasBusyStateMixin from 'tahi/mixins/has-busy-state';
import { module, test } from 'qunit';

module('Unit | Mixin | has busy state');

test('busyWhile sets and unsets busy property', function(assert) {
  let HasBusyStateObject = Ember.Object.extend(HasBusyStateMixin);
  let subject = HasBusyStateObject.create();

  assert.notOk(subject.get('busy'));

  const start = assert.async();

  const busyPromise = new Ember.RSVP.Promise(function (resolve, reject) {
    let tries = 0;
    let f = function () {
      tries += 1;
      const busy = subject.get('busy');
      if (busy !== true) {
        if (tries > 3) {
          assert.notOk(busy, 'Waited too long to set busy.');
          reject();
        } else {
          setTimeout(f, 10);
        }
      } else {
        assert.ok(busy);
        resolve();
      }
    };
    // We have no guarantee that the busy state will be set before this code
    // runs, so we need to poll until we see that it is set.
    setTimeout(f, 10);
  });

  subject.busyWhile(busyPromise).finally(() => {
    assert.notOk(subject.get('busy'));
    start();
  });
});
