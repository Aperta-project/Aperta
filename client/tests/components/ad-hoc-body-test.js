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
    save=(action fakeSave)
    blocks=task.body
    canManage=canManage
    canEdit=canEdit}}`;


test('canManage=true adding new blocks', function(assert) {
  // adding a text block immediately persists the new block to the task body
  let savecount = 0;
  let task = make('task', {body: []});
  this.set('task', task);
  this.set('fakeSave', function() { savecount += 1; });
  this.set('canEdit', false);
  this.set('canManage', false);
  this.render(template);
  assert.elementNotFound('.adhoc-content-toolbar', `does not show the content toolbar when canManage is false`);

  this.set('canManage', true);
  assert.elementFound('.adhoc-content-toolbar', `shows the content toolbar`);

  // Checkbox list
  this.$('.admin-content-toolbar').click();
  this.$('.adhoc-content-toolbar .adhoc-toolbar-item--list').click();
  this.$('.inline-edit-body-part.checkbox label.editable').html('I am a nice checkbox');
  this.$('.inline-edit-body-part.checkbox label.editable').keyup();
  this.$('.edit-actions .button-secondary').click(); // click save
  assert.textPresent('.inline-edit.bodypart-display.checkbox ', 'I am a nice checkbox', `checkbox added to page`);

  // User editable text
  this.$('.admin-content-toolbar').click();
  assert.elementFound('.adhoc-toolbar-item--text', `can insert a text item`);
  this.$('.adhoc-content-toolbar .adhoc-toolbar-item--text').click();
  assert.elementFound('.inline-edit-body-part.text', `shows the text item`);

  // Label text
  this.$('.admin-content-toolbar').click();
  assert.elementFound('.adhoc-toolbar-item--label', `can insert a label`);
  this.$('.adhoc-content-toolbar .adhoc-toolbar-item--label').click();
  assert.elementFound('.inline-edit-body-part.adhoc-label', `label added to card`);
  this.$('.inline-edit-body-part.adhoc-label editable').val('I am a nice label');
  this.$('.inline-edit-body-part.adhoc-label editable').keyup();
  this.$('.edit-actions .button-secondary').click();

  // Email
  this.$('.admin-content-toolbar').click();
  assert.elementFound('.adhoc-toolbar-item--email', `can insert an email`);
  this.$('.adhoc-content-toolbar .adhoc-toolbar-item--email').click();
  assert.elementFound('.inline-edit-body-part.email', `email added to card`);
  this.$('.inline-edit-body-part.email ember-text-field').val('This is a nice little subject');
  this.$('.inline-edit-body-part.email ember-text-field').keyup();
  this.$('.inline-edit-body-part.email editable').val('This is a nice little email');
  this.$('.inline-edit-body-part.email editable').keyup();
  this.$('.edit-actions .button-secondary').click();

  // Attachment
  this.$('.admin-content-toolbar').click();
  assert.elementFound('.adhoc-toolbar-item--image', `can insert an attachment`);

  assert.equal(savecount, 4, `expected number of times to call save`);
});

let taskWithBlocks = function() {
  let checkBoxBlock = [{type: 'checkbox', value: 'foo', answer: 'true'}];
  let textBlock = [{type: 'text',  value: 'text value'}];
  let labelBlock = [{type: 'adhoc-label',  value: 'label text'}];
  let emailBlock = [{type: 'email',  subject: 'email subjet', value: 'label text', sent: ''}];
  return make(
    'task',
    {body: [
      checkBoxBlock,
      textBlock,
      labelBlock,
      emailBlock ]
    });
};

let cannotManageElement = function(assert, selector) {
  assert.elementNotFound(selector + ' .fa-pencil');
  assert.elementNotFound(selector + ' .fa-trash');
};

test('canManage=false, viewing existing blocks', function(assert) {
  let checkCannotManage = _.partial(cannotManageElement, assert);
  this.set('task', taskWithBlocks());
  this.set('fakeSave', function() {});
  this.set('canEdit', true);
  this.set('canManage', false);
  this.render(template);

// check box
  checkCannotManage('.inline-edit-body-part.checkbox');

// existing text blocks cannot be edited with the pencil, and they are disabled for users who canManage
  checkCannotManage('.inline-edit-body-part.text');

// labels can be edited and deleted
  checkCannotManage('.inline-edit-body-part.adhoc-label');

// check box
  checkCannotManage('.inline-edit-body-part.email');
});

test('canEdit=true editing text areas save on focusOut', function(assert) {
  let savecount = 0;
  this.set('fakeSave', function() { savecount += 1; });
  this.set('task', taskWithBlocks());
  this.set('canEdit', true);
  this.set('canManage', false);
  this.render(template);

  this.$('.bodypart-display.text .editable')
    .html('User inserts some interesting text')
    .focusout();

  assert.equal(savecount, 1, `expect 1 save calls`);
});

test('canEdit=true filling out some stuff still works', function(assert) {
  let savecount = 0;
  this.set('fakeSave', function() { savecount += 1; });
  this.set('canEdit', true);
  this.set('canManage', false);
  let checkBoxBlock = [{type: 'checkbox', value: 'foo', answer: 'false'}];
  let textBlock = [{type: 'text',  value: 'text value'}];
  let labelBlock = [{type: 'adhoc-label',  value: 'label text'}];
  let emailBlock = [{type: 'email',  subject: 'email subjet', value: 'label text', sent: ''}];
  this.set('task', make(
    'task',
    {body: [
      checkBoxBlock,
      textBlock,
      labelBlock,
      emailBlock ]
    }));
  this.render(template);
  /*
   *
   * - checkboxes call save on click
   * - text blocks call save on blur?
   * - labels are only shown in a display state
   * - can send emails
   */

  // Checkboxes save on clicking
  this.$('.inline-edit.bodypart-display.checkbox .ember-checkbox').click();
  assert.equal(savecount, 1, `Expect saves for user actions`);
  assert.equal(checkBoxBlock[0].answer, true);

  // Text blocks save on user blur
  this.$('.bodypart-display.text .editable')
    .html('User inserts some interesting text')
    .keyup()
    .focusout();
  assert.equal(textBlock[0].value, 'User inserts some interesting text');
  assert.equal(savecount, 2, `textbox saves on focusout`);

  // Nothing special happens to labels for editing

  // Emails send in any state

  // File uploads need to be specified
});

test('canEdit=false all fields are disabled', function(assert) {
  this.set('canEdit', false);
  this.set('canManage', false);
  this.set('task', taskWithBlocks());
  this.render(template);

  // Checkboxes are disabled
  assert.elementFound('.bodypart-display.checkbox .ember-checkbox[disabled]');

  // Text boxes are not editable
  assert.elementNotFound('.bodypart-display.text .editable[contenteditable]');

  // Emails send in any state
  assert.elementFound('.bodypart-display.email .email-send-participants',`emails can always be sent`);
});

