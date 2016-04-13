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

  let snapshot1 = {contents: {children: viewing}};
  let snapshot2 = {contents: {children: comparing}};

  this.component.setProperties({snapshot1, snapshot2});
  let authors = this.component.get('authors');

  assert.equal(authors.length, 3, 'there are three authors');
  authors.map((author, idx) => {
    assert.deepEqual(authors[idx][0], viewing[idx], `author ${idx + 1} viewing matches`);
    assert.deepEqual(authors[idx][1], comparing[idx]), `author ${idx + 1} comparing matches`;
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

  let snapshot1 = {contents: {children: viewing}};
  let snapshot2 = {contents: {children: comparing}};

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

  let snapshot1 = {contents: {children: viewing}};
  let snapshot2 = {contents: {children: comparing}};

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

  let snapshot1 = {contents: {children: viewing}};
  let snapshot2 = {contents: {children: comparing}};

  this.component.setProperties({snapshot1, snapshot2});
  let authors = this.component.get('authors');

  assert.equal(authors.length, 2, 'there are two authors in the diff');
  assert.deepEqual(authors[1][0], viewing[1]);
  assert.equal(authors[1][1], null);
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

  let snapshot1 = {contents: {children: viewing}};
  let snapshot2 = {contents: {children: comparing}};

  this.component.setProperties({snapshot1, snapshot2});
  let authors = this.component.get('authors');

  assert.equal(authors.length, 3, 'there are three authors in the diff');
  assert.deepEqual(authors[1][0], viewing[1]);
  assert.equal(authors[1][1], null);
  assert.equal(authors[2][0], null);
  assert.deepEqual(authors[2][1], comparing[1]);
});


