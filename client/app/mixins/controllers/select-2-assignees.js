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

export default Ember.Mixin.create({
  select2RemoteSource: Ember.computed('select2RemoteUrl', function() {
    return {
      url: this.get('select2RemoteUrl'),
      dataType: 'json',
      quietMillis: 500,
      data(term) {
        return {
          query: term
        };
      },
      results(data) {
        return {
          results: data.users
        };
      }
    };
  }),

  resultsTemplate(user) {
    let email = (typeof(user.email) === 'string') ? user.email : user.get('email');

    if (user.full_name) {
      let fullName = user.full_name;
      return `${fullName} <span class="select2-assignee-email">[${email}]</span>`;
    } else {
      return `${email} <span class="select2-assignee-email">[${email}]</span>`;
    }
  }
});
