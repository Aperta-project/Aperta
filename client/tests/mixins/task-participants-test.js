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

import { module, test } from 'qunit';
import Ember from 'ember';
import TaskParticipantsMixin from 'tahi/mixins/components/task-participants';

const FakeObject = Ember.Object.extend(TaskParticipantsMixin);

module('Unit | Mixin | Task Participants ', {
  beforeEach() {
    this.object = FakeObject.create();
  }
});

test('#assignedUser it returns an array with a single user when assigned', function(assert) {
  let user = Ember.Object.create({id: 1});
  this.object.set('task', Ember.Object.create({assignedUser: user}));
  this.object.get('saveAssignedUser', user);

  assert.equal(this.object.get('assignedUser').length, 1);
  assert.equal(this.object.get('assignedUser')[0], user);
});

test('#assignedUser it returns an empty array when user is not yet assigned', function(assert) {
  let user = Ember.Object.create();
  this.object.set('task', Ember.Object.create({assignedUser: user}));

  assert.equal(this.object.get('assignedUser').length, 0);
});
