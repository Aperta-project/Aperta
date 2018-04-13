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


moduleFor('service:feedback', 'Unit | Service | Feedback',
          {integration: true});


test('sendFeedback calls Restless with the appropriate params', function(assert) {
  let shots = [];
  let referrerAddress = "http://localhost";
  let remarkText = "I have feedback";

  let fakeRestless = {
    post: sinon.spy()
  };

  let fakePaper = {
    id: 42
  };

  let service = this.subject({restless: fakeRestless});
  service.setContext(fakePaper);

  service.sendFeedback(referrerAddress, remarkText, shots);

  // if this fails use `sinon.assert.calledWith` to diagnose
  assert.ok(fakeRestless.post.calledWith(
    '/api/feedback', {
      feedback: {
        referrer: referrerAddress,
        remarks: remarkText,
        paper_id: fakePaper.id,
        screenshots: shots
      }
    }));
});
