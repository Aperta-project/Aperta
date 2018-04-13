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

import {
  moduleFor,
  test
} from 'ember-qunit';

import Ember from 'ember';

moduleFor('component:author-task-snapshot', 'Unit: components/author-task-snaphot', {

  beforeEach: function() {
    this.component = this.subject();
  }
});


let createAuthor = function(id, type, position, diffedObj) {
      return {
        'name': type,
        'type': 'properties',
        'children': [
          {
            'name': 'id',
            'type': 'integer',
            'value': id
          },
          {
            'name': 'position',
            'type': 'integer',
            'value': position
          },
          diffedObj
        ]
      };
};

test('Finds no differences when there are none', function(assert) {

  let sameAttr = {name: 'some-attribute', type: 'type', value: 'diffable'};

  let viewing = [
    createAuthor(1, 'author', 1, sameAttr),
    createAuthor(2, 'author', 2, sameAttr),
    createAuthor(1, 'group-author', 3, sameAttr)
  ];

  let comparing = [
    createAuthor(1, 'author', 1, sameAttr),
    createAuthor(2, 'author', 2, sameAttr),
    createAuthor(1, 'group-author', 3, sameAttr)
  ];

  let snapshot1 = {children: viewing};
  let snapshot2 = {children: comparing};

  this.component.setProperties({snapshot1, snapshot2});
  let authors = this.component.get('authors');

  assert.equal(authors.length, 3, 'there are three authors');
  authors.map((author, idx) => {
    assert.deepEqual(authors[idx][0], viewing[idx], `author ${idx + 1} viewing matches`);
    assert.deepEqual(authors[idx][1], comparing[idx], `author ${idx + 1} comparing matches`);
  });

});

test('Finds position differences in lists with the same authors', function(assert) {

  let sameAttr = {name: 'some-attribute', type: 'type', value: 'diffable'};

  let viewing = [
    createAuthor(1, 'author', 1, sameAttr),
    createAuthor(2, 'author', 2, sameAttr),
    createAuthor(1, 'group-author', 3, sameAttr)
  ];

  let comparing = [
    createAuthor(1, 'author', 1, sameAttr),
    createAuthor(1, 'group-author', 2, sameAttr),
    createAuthor(2, 'author', 3, sameAttr)
  ];

  let snapshot1 = {children: viewing};
  let snapshot2 = {children: comparing};

  this.component.setProperties({snapshot1, snapshot2});
  let authors = this.component.get('authors');

  assert.equal(authors.length, 3, 'there are three authors');
  assert.deepEqual(authors[0][0], authors[0][1], 'first author unchanged');
  assert.deepEqual(authors[1][0], viewing[1]);
  assert.deepEqual(authors[2][0], viewing[2]);
  assert.deepEqual(authors[1][1], comparing[2]);
  assert.deepEqual(authors[2][1], comparing[1]);
});

test('An author was removed', function(assert) {

  let sameAttr = {name: 'some-attribute', type: 'type', value: 'diffable'};

  let viewing = [
    createAuthor(1, 'author', 1, sameAttr),
  ];

  let comparing = [
    createAuthor(1, 'author', 1, sameAttr),
    createAuthor(2, 'author', 2, sameAttr),
  ];

  let snapshot1 = {children: viewing};
  let snapshot2 = {children: comparing};

  this.component.setProperties({snapshot1, snapshot2});
  let authors = this.component.get('authors');
  assert.equal(authors.length, 2, 'there are still two authors in the diff');
  assert.equal(authors[1][0], null);
  assert.deepEqual(authors[1][1], comparing[1]);
});

test('An author was added', function(assert) {

  let sameAttr = {name: 'some-attribute', type: 'type', value: 'diffable'};

  let viewing = [
    createAuthor(1, 'author', 1, sameAttr),
    createAuthor(2, 'author', 2, sameAttr),
  ];

  let comparing = [
    createAuthor(1, 'author', 1, sameAttr),
  ];

  let snapshot1 = {children: viewing};
  let snapshot2 = {children: comparing};

  this.component.setProperties({snapshot1, snapshot2});
  let authors = this.component.get('authors');

  assert.equal(authors.length, 2, 'there are two authors in the diff');
  assert.deepEqual(authors[1][0], viewing[1]);
  assert.ok(_.isEmpty(authors[1][1]));
});

test('An author was added and removed', function(assert) {

  let sameAttr = {name: 'some-attribute', type: 'type', value: 'diffable'};

  let viewing = [
    createAuthor(1, 'author', 1, sameAttr),
    createAuthor(2, 'author', 2, sameAttr),
  ];

  let comparing = [
    createAuthor(1, 'author', 1, sameAttr),
    createAuthor(1, 'group-author', 2, sameAttr),
  ];

  let snapshot1 = {children: viewing};
  let snapshot2 = {children: comparing};

  this.component.setProperties({snapshot1, snapshot2});
  let authors = this.component.get('authors');

  assert.equal(authors.length, 3, 'there are three authors in the diff');
  assert.deepEqual(authors[1][0], viewing[1]);
  assert.ok(_.isEmpty(authors[1][1]));
  assert.equal(authors[2][0], null);
  assert.deepEqual(authors[2][1], comparing[1]);
});
