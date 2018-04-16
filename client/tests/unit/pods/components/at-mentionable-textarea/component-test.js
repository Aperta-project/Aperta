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

moduleForComponent('at-mentionable-textarea', 'Unit | Component | at mentionable textarea', {
  unit: true
});

const charmander = {
  username: 'charmander',
  email: 'fire@oak.edu',
  name: 'Charmander Pokemon'
};

const bulbasaur = {
  username: 'bulbasaur',
  email: 'plant@oak.edu',
  name: 'Bulbasaur Pokemon'
};

const squirtle = {
  username: 'squirtle',
  email: 'water@oak.edu',
  name: 'Squirtle Pokemon (not Bulbasaur)'
};

let userList = [charmander, bulbasaur, squirtle];

test('#indexOfString', function(assert) {
  const component = this.subject({ atMentionableUsers: userList });
  assert.equal(component.indexOfString('Turtle', 'Tur'), 0);
  assert.equal(component.indexOfString('Turtle', 'tur'), 0);
  assert.equal(component.indexOfString('Turtle', 'urt'), 1);
  assert.equal(component.indexOfString('Turtle', 'uRt'), 1);
  assert.equal(component.indexOfString('Turtle', 'Human'), -1);
});

test('#containsString', function(assert) {
  const component = this.subject({ atMentionableUsers: userList });
  assert.ok(component.containsString('Turtle', 'Tur'));
  assert.ok(component.containsString('Turtle', 'tur'));
  assert.ok(component.containsString('Turtle', 'tle'));
  assert.ok(component.containsString('Turtle', ''));
  assert.notOk(component.containsString('Turtle', 'Human'));
});

test('#filter', function(assert) {
  const data = [charmander, bulbasaur, squirtle];
  const component = this.subject({ atMentionableUsers: data });
  const testCase = function(query, expected, msg) {
    assert.deepEqual(component.filter(query, data), expected, msg);
  };

  testCase('pokemon', data, 'matching on part of a full name');
  testCase('digimon', [], 'matching on something that does not match');
  testCase('', data, 'matching on empty string');
  testCase('oak.edu', data, 'matching on partial email');
  testCase('charmander', [charmander], 'filtering on username');
});

/* eslint-disable camelcase */

test('#sorter', function(assert){
  const data = [squirtle, bulbasaur];
  const component = this.subject({ atMentionableUsers: data });
  const testCase = function(query, expected, msg) {
    const sorted_items = component.sorter(query, data);
    const sorted_names = _.map(sorted_items, function(i) { return i.name; });
    const expected_names = _.map(expected, function(i) { return i.name; });
    assert.deepEqual(sorted_names, expected_names, msg);
  };

/* eslint-enable camelcase */

  testCase('Bulbasaur', [bulbasaur, squirtle],
    'it should sort by matches in the username first');
  testCase('oak.edu', [squirtle, bulbasaur],
    'it sorts by the index of the match in the user\'s concatenated details');
});

/* eslint-disable max-len */

test('#highlighter', function(assert){
  const component = this.subject({ atMentionableUsers: userList });
  const query = 'char';
  const li = '<li><span class="at-who-name">Charmander Pokémon</span> <span class="at-who-username">@jcharmander</span> <span class="at-who-email">fire@oak.edu</span></li>';
  const expected = '<li><span class="at-who-name"><strong>Char</strong>mander Pokémon</span> <span class="at-who-username">@j<strong>char</strong>mander</span> <span class="at-who-email">fire@oak.edu</span></li>';
  assert.equal(component.highlighter(li, query), expected);
});

/* eslint-enable max-len */
