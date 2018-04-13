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

import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';

moduleForComponent('at-mentionable-textarea', 'Integration | Component | at mentionable textarea', {
  integration: true
});

const charmander = Ember.Object.create({
  username: 'charmander',
  email: 'fire@oak.edu',
  name: 'Charmander Pokemon'
});

const bulbasaur = Ember.Object.create({
  username: 'bulbasaur',
  email: 'plant@oak.edu',
  name: 'Bulbasaur Pokemon'
});

const squirtle = Ember.Object.create({
  username: 'squirtle',
  email: 'water@oak.edu',
  name: 'Squirtle Pokemon (not Bulbasaur)'
});

test('it displays user names when a @ is typed', function(assert) {
  this.userList = [charmander, bulbasaur, squirtle];

  this.render(hbs`{{at-mentionable-textarea atMentionableUsers=userList}}`);
  const textarea = this.$('textarea');
  textarea.val('@');
  textarea.keyup();

  let atWhoItems = $('.atwho-container li');
  assert.equal(atWhoItems.length, 3);

  atWhoItems.each((i, item) => {
    const itemName = $(item).find('.at-who-name').text();
    const expectedItemName = this.userList[i].get('name');
    assert.equal(itemName, expectedItemName);
  });

  // now filter the list
  textarea.val('@char');
  textarea.keyup();

  atWhoItems = $('.atwho-container li');
  assert.equal(atWhoItems.length, 1, 'two users are filtered out');
  const firstName = atWhoItems.eq(0).find('.at-who-name').text();
  assert.equal(firstName, charmander.name);
});

test('it cleans up after itself', function(assert) {
  this.userList = [charmander, bulbasaur, squirtle];

  this.render(hbs`{{at-mentionable-textarea atMentionableUsers=userList}}`);
  assert.equal($('.atwho-container').length, 1);
  this.render(hbs``);
  assert.equal($('.atwho-container').length, 0);
});
