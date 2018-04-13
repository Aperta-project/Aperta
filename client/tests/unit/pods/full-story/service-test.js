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
import sinon from 'sinon';
import { moduleFor, test } from 'ember-qunit';

moduleFor('service:full-story', 'Unit | Service | full story', {
  beforeEach() {
    this.service = this.subject();
  }
});

const currentUser = Ember.Object.create({
  username: 'pikachu',
  email: 'pikachu@oak.edu',
  fullName: 'Pikachu Pokémon'
});

function withFS(test) {
  const identifySpy = sinon.spy();
  const clearUserCookieSpy = sinon.spy();
  const fs = window.FS;
  window.FS = {
    identify: identifySpy,
    clearUserCookie: clearUserCookieSpy
  };
  test.call(this, identifySpy, clearUserCookieSpy);
  window.FS = fs;
}

function withoutFS(test) {
  const fs = window.FS;
  delete window.FS;
  test.call();
  window.FS = fs;
}

test('identify() when FS is loaded', function(assert) {
  withFS((identifySpy) => {
    this.service.identify(currentUser);
    assert.spyCalledWith(
      identifySpy,
      [
        currentUser.get('username'),
        {
          email: currentUser.get('email'),
          displayName: currentUser.get('fullName')
        }
      ],
      'identify should be called with user details'
    );
  });
});

test('identify() when FS is not loaded', function(assert){
  withoutFS(() => {
    this.service.identify(currentUser);
    assert.ok('things should not blow up');
  });
});

test('clearSession() when FS is loaded', function(assert){
  withFS((_, clearUserCookieSpy) => {
    this.service.clearSession();
    assert.spyCalled(clearUserCookieSpy);
  });
});

test('clearSession() when FS is not loaded', function(assert){
  withoutFS(() => {
    this.service.clearSession();
    assert.ok('things should not blow up');
  });
});
