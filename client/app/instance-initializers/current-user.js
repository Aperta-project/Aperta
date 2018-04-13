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

export default {
  name: 'current-user',

  initialize(instance) {
    const data = window.currentUserData;
    if($.isEmptyObject(data)) { return; }

    const store = instance.lookup('service:store');
    store.pushPayload(data);

    let user = store.peekRecord('user', data.user.id);
    instance.register('service:currentUser', user, {
      instantiate: false
    });

    instance.inject('controller', 'currentUser', 'service:currentUser');
    instance.inject('route',      'currentUser', 'service:currentUser');
    instance.inject('component', 'currentUser', 'service:currentUser');
    instance.inject('model:author', 'currentUser', 'service:currentUser');
    instance.inject('service:notifications', 'currentUser',  'service:currentUser');
  }
};
