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

let App = null;

moduleForAcceptance('Integration: Feedback Form', {
  afterEach: function() {
    Ember.run(App, 'destroy');
  },

  beforeEach: function() {
    App = startApp();
    $.mockjax({url: '/api/admin/journals/authorization', status: 204});
    $.mockjax({url: '/api/affiliations', status: 304 });

    $.mockjax({
      url: '/api/journals',
      method: 'GET',
      status: 200,
      responseText: { journals: [] }
    });
    $.mockjax({
      url: '/api/feedback',
      method: 'POST',
      status: 201,
      responseText: {}
    });
  }
});

test('clicking the feedback button sends feedback', function(assert) {
  visit('/');
  click('#nav-give-feedback');
  click('a:contains(Feedback)');
  fillIn('.overlay textarea', 'My feedback');
  click('.overlay-footer-content .button-primary');

  andThen(function() {
    assert.elementFound(
      '.feedback-form-thanks',
      'Thank you message visible'
    );
  });
});
