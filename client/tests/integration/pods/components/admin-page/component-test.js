import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup } from 'ember-data-factory-guy';
import FakeCanService from 'tahi/tests/helpers/fake-can-service';

const featureFlagServiceStub = Ember.Service.extend ({
  flags: {
    CARD_CONFIGURATION: true
  },

  value(flag){
    return this.get('flags')[flag];
  }
});

moduleForComponent('admin-page', 'Integration | Component | Admin Page', {
  integration: true,
  beforeEach: function() {
    // this avoids a weird error with the feature flag service: Uncaught[Object object]
    manualSetup(this.container);
    this.register('service:feature-flag', featureFlagServiceStub);
    this.register('service:can', FakeCanService);
  }
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
  let fake = this.container.lookup('service:can');
  let journal = FactoryGuy.make('journal', {isNew: false });
  let journal2 = FactoryGuy.make('journal', {isNew: false });
  const journals = [ journal, journal2];
  fake.allowPermission('administer', journal);

  this.set('journals', journals);
  this.set('journal', journals[0]);

  this.render(hbs`
    {{#admin-page journals=journals journal=journal}}
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

  let journalProps1 = { name: 'Zebra', initials: 'Z', id: 1, isNew: false };
  let journalProps2 = { name: 'Apple', initials: 'A', id: 2, isNew: false };

  let fake = this.container.lookup('service:can');
  let journal = FactoryGuy.make('journal', journalProps1);
  let journal2 = FactoryGuy.make('journal', journalProps2);
  const journals = [ journal, journal2];
  fake.allowPermission('administer', journal);

  this.set('journals', journals);
  this.set('journal', journals[0]);

  this.render(hbs`
    {{#admin-page journals=journals journal=journal}}
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
  let journalProps1 = { name: 'My Journal', initials: 'MJ', id: 1, isNew: false };
  let journalProps2 = { name: 'My Secondary', initials: 'MS', id: 2, isNew: false };

  let fake = this.container.lookup('service:can');
  let journal = FactoryGuy.make('journal', journalProps1);
  let journal2 = FactoryGuy.make('journal', journalProps2);
  const journals = [ journal, journal2];
  fake.allowPermission('administer', journal);

  this.set('journals', journals);
  this.set('journal', journals[0]);

  this.render(hbs`
    {{#admin-page journals=journals journal=journal}}
      Some interesting text.
    {{/admin-page}}
  `);

  assert.textPresent('.left-drawer-page', 'All My Journals');
});

test('it has a drawer without "all journals" for single journal', function(assert) {
  let journalProps1 = { name: 'My Secondary', initials: 'MS', id: 2, isNew: false };

  let fake = this.container.lookup('service:can');
  let journal = FactoryGuy.make('journal', journalProps1);
  fake.allowPermission('administer', journal);

  this.set('journals', [journal]);
  this.set('journal', journal);

  this.render(hbs`
    {{#admin-page journals=journals journal=journal}}
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
