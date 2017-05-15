import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('admin-page', 'Integration | Component | Admin Page', {
  integration: true
});

test('it has a tab bar', function(assert) {
  this.render(hbs`
    {{#admin-page}}
      Does this have a tab bar?
    {{/admin-page}}
  `);

  assert.elementFound('.admin-tab-bar');
});

test('it has a drawer showing all persisted journals', function(assert) {
  const journals = [
    { name: 'My Journal', initials: 'MJ', id: 1, isNew: false },
    { name: 'My Secondary', initials: 'MS', id: 2, isNew: false }
  ];

  this.set('journals', journals);

  this.render(hbs`
    {{#admin-page journals=journals}}
      Some interesting text.
    {{/admin-page}}
  `);

  // "All My Journals" will be shown for multiple journals
  assert.nElementsFound('.admin-drawer-item', journals.length + 1);
});

test('it does not show unpersisted journals in the drawer', function(assert) {
  const journals = [
    { name: 'My Journal', initials: 'MJ', id: 1, isNew: true }
  ];

  this.set('journals', journals);

  this.render(hbs`
    {{#admin-page journals=journals}}
      Some interesting text.
    {{/admin-page}}
  `);

  assert.nElementsFound('.admin-drawer-item', 0);
});

test('it alphabetizes the list of journals', function(assert) {
  const journals = [
    { name: 'Zebra', initials: 'Z', id: 1, isNew: false },
    { name: 'Apple', initials: 'A', id: 2, isNew: false }
  ];

  this.set('journals', journals);

  this.render(hbs`
    {{#admin-page journals=journals}}
      Some interesting text.
    {{/admin-page}}
  `);

  let actualOrderedJournalNames = $('.admin-drawer-item-title').map((_, el) => {
    return $(el).html().trim();
  }).get();
  let expectedOrderedJournalNames = journals.mapBy('name').sort();

  // "All My Journals" will be shown for multiple journals
  expectedOrderedJournalNames.unshift('All My Journals');

  assert.deepEqual(actualOrderedJournalNames, expectedOrderedJournalNames, 'journals not in alphabetical order');
});

test('it has a drawer with "all journals" for multiple journals', function(assert) {
  const journals = [
    { name: 'My Journal', initials: 'MJ', id: 1, isNew: false },
    { name: 'My Secondary', initials: 'MS', id: 2, isNew: false },
  ];

  this.set('journals', journals);

  this.render(hbs`
    {{#admin-page journals=journals}}
      Some interesting text.
    {{/admin-page}}
  `);

  assert.textPresent('.left-drawer-page', 'All My Journals');
});

test('it has a drawer without "all journals" for single journal', function(assert) {
  const journals = [
    { name: 'My Secondary', initials: 'MS', id: 2, isNew: false }
  ];

  this.set('journals', journals);

  this.render(hbs`
    {{#admin-page journals=journals}}
      Some interesting text.
    {{/admin-page}}
  `);

  assert.textNotPresent('.left-drawer-page', 'All My Journals');
});

test('it renders the admin page', function(assert) {

  this.render(hbs`
    {{#admin-page}}
      Some content goes here
    {{/admin-page}}
  `);

  assert.textPresent('.admin-page-content', 'Some content goes here');
});
