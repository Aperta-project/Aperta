import { test, moduleForComponent } from 'ember-qunit';
import wait from 'ember-test-helpers/wait';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make } from 'ember-data-factory-guy';
import registerCustomAssertions from '../helpers/custom-assertions';

moduleForComponent('ad-hoc-body', 'Integration | Component | ad-hoc body', {
  integration: true,
  beforeEach() {
    registerCustomAssertions();
    manualSetup(this.container);
  }
});

let template = hbs
`{{ad-hoc-body task=task
blocks=task.body
canManage=canManage
canEdit=canEdit}}`;

test('can manage ad-hoc-cards', function(assert){
  //TODO: use adhoc task after APERTA-7727 is merged
  let task = make('task', {body: []});
  this.set('task', task);
  this.set('fakeSave', function() {console.log('gotit')});
  this.set('canEdit', false);
  this.set('canManage', true);
  this.render(template);

  assert.elementFound('.adhoc-content-toolbar');

  this.$('.admin-content-toolbar').click();
  assert.elementFound('.adhoc-toolbar-item--list');
  this.$('.adhoc-content-toolbar .adhoc-toolbar-item--list').click();
  assert.elementFound('.inline-edit-body-part.checkbox');
  this.$('.inline-edit-body-part.checkbox editable').val('I am a nice checkbox');
  this.$('.inline-edit-body-part.checkbox editable').change();
  this.$('.edit-actions .button-secondary').click();
  assert.elementFound('.inline-edit-body-part.checkbox .fa-pencil');
  assert.elementFound('.inline-edit-body-part.checkbox .fa-trash');

  // text, label, email, image
  this.$('.admin-content-toolbar').click();
  assert.elementFound('.adhoc-toolbar-item--text');
  this.$('.adhoc-content-toolbar .adhoc-toolbar-item--text').click();
  assert.elementFound('.inline-edit-body-part.text');
  assert.elementFound('.inline-edit-body-part.checkbox .fa-trash');

  this.$('.admin-content-toolbar').click();
  assert.elementFound('.adhoc-toolbar-item--label');
  this.$('.adhoc-content-toolbar .adhoc-toolbar-item--label').click();
  assert.elementFound('.inline-edit-body-part.adhoc-label');
  this.$('.inline-edit-body-part.adhoc-label editable').val('I am a nice checkbox');
  this.$('.inline-edit-body-part.adhoc-label editable').change();
  this.$('.edit-actions .button-secondary').click();
  assert.elementFound('.inline-edit-body-part.adhoc-label .fa-pencil');
  assert.elementFound('.inline-edit-body-part.adhoc-label .fa-trash');
});

test('can edit ad-hoc-cards', function(assert) {
});

