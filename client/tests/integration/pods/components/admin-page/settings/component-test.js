import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('admin-page/settings',
                   'Integration | Component | Admin Page | Settings', {
                     integration: true
                   });

const journal = { name: 'My Journal' };

test('it renders the journal editing form', function(assert) {
  this.set('journal', journal);

  this.render(hbs`
    {{admin-page/settings journal=journal}}
  `);

  assert.elementFound('.journal-thumbnail-edit-form');
});

test('it renders the journal css editing buttons', function(assert) {
  this.set('journal', journal);

  this.render(hbs`
    {{admin-page/settings journal=journal}}
  `);

  assert.nElementsFound('.admin-journal-settings-buttons button', 2);
});

test('it prevents showing form when no journal is selected', function(assert) {
  this.set('journal', null);

  this.render(hbs`
    {{admin-page/settings journal=journal}}
  `);

  assert.elementNotFound('.journal-thumbnail-edit-form');
  assert.textPresent('.admin-journal-settings', 'select a specific journal');
});
