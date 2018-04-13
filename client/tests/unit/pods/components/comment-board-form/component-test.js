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
import { moduleForComponent, test } from 'ember-qunit';

moduleForComponent('comment-board-form', 'Unit | Component | comment board form', {
  unit: true
});

const charmander = {
  username: 'charmander',
  email: 'fire@oak.edu',
  name: 'Charmander Pokémon'
};

const bulbasaur = Ember.Object.create({
  username: 'bulbasaur',
  email: 'plant@oak.edu',
  name: 'Bulbasaur Pokemon'
});

test('#atMentionableUsers does not have duplicates', function(assert) {
  const userA = Ember.Object.create(charmander);
  const userB = Ember.Object.create(charmander);

  const component = this.subject({
    participants: [userA],
    atMentionableStaffUsers: [userB]
  });

  assert.equal(component.get('atMentionableUsers.length'), 1,
               'it should contain no duplicates');
});

test('#atMentionableUsers does not have the current user', function(assert) {
  const otherUser = Ember.Object.create(charmander);
  const currentUser = Ember.Object.create(bulbasaur);

  const component = this.subject({
    participants: [otherUser, currentUser],
    currentUser
  });

  assert.deepEqual(component.get('atMentionableUsers'), [otherUser]);
});

test('#atMentionableUsers updates when a participant is removed',
function(assert) {
  const user = Ember.Object.create(charmander);
  const users = Ember.A([user]);

  const component = this.subject({
    participants: users
  });

  assert.deepEqual(component.get('atMentionableUsers'), [user]);
  users.popObject();
  assert.deepEqual(component.get('atMentionableUsers'), []);
});
