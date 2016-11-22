import { test, moduleForComponent } from 'ember-qunit';
// import wait from 'ember-test-helpers/wait';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make } from 'ember-data-factory-guy';
import registerCustomAssertions from '../helpers/custom-assertions';
import page from '../pages/ad-hoc-task';
import FakeCanService from '../helpers/fake-can-service';

moduleForComponent('ad-hoc-body', 'Integration | Component | ad-hoc body', {
  integration: true,
  beforeEach() {
    page.setContext(this);
    registerCustomAssertions();
    manualSetup(this.container);
    this.registry.register('service:can', FakeCanService);
  },

  afterEach() {
    page.removeContext();
  }
});

let template = hbs`{{ad-hoc-body task=task
                    save=(action fakeSave)
                    blocks=task.body
                    canManage=canManage
                    canEdit=canEdit}}`;

test('canManage=true adding new blocks', function(assert) {
  // adding a text block immediately persists the new block to the task body
  let savecount = 0;
  let task = make('ad-hoc-task', {body: []});

  let fake = this.container.lookup('service:can');
  fake.allowPermission('add_email_participants', task);

  this.set('task', task);
  this.set('fakeSave', function() { savecount += 1; });
  this.set('canEdit', false);
  this.set('canManage', false);
  this.render(template);

  assert.notOk(page.toolbarVisible, `does not show the content toolbar when canManage is false`);

  this.set('canManage', true);
  assert.ok(page.toolbarVisible, `shows the content toolbar`);

  // Checkbox list
  page.toolbar.open();
  page.toolbar.addCheckbox();
  page.checkboxes(0).labelText('I am a nice checkbox');
  page.checkboxes(0).save();
  assert.ok(page.checkboxes(0).editVisible, `checkboxes are editable (manageable)`);
  assert.ok(page.checkboxes(0).deleteVisible, `checkboxes are deletable (manageable)`);
  assert.equal(page.checkboxes(0).label, 'I am a nice checkbox', `checkbox added to page`);

  // User editable text
  page.toolbar.open();
  page.toolbar.addText();
  assert.notOk(page.textboxes(0).editVisible, `textboxes are not editable (manageable)`);
  assert.ok(page.textboxes(0).deleteVisible, `textboxes are deletable (manageable)`);
  assert.equal(page.textboxes().count, 1);

  // Label text
  page.toolbar.open();
  page.toolbar.addLabel();
  page.labels(0).labelText('I am a nice label');
  page.labels(0).save();
  assert.equal(page.labels(0).text, 'I am a nice label', `label added to card`);
  assert.ok(page.labels(0).editVisible, `labels are editable (manageable)`);
  assert.ok(page.labels(0).deleteVisible, `labels are deletable (manageable)`);

  // Email
  page.toolbar.open();
  page.toolbar.addEmail();
  page.emails(0).setSubject('This is a nice little subject');
  page.emails(0).setBody('This is a nice little email');
  page.emails(0).save();
  let expectedSubject = 'Subject: This is a nice little subject';
  assert.equal(page.emails(0).subject, expectedSubject, `subject added to email`);
  assert.equal(page.emails(0).body, expectedSubject + ' This is a nice little email', `body added to email`);

  page.emails(0).send();
  assert.ok(page.emails(0).sendConfirmDisabled, `emails cannot send without recipients`);
  page.emails(0).cancel();

  assert.ok(page.emails(0).editVisible, `emails are editable (manageable)`);
  assert.ok(page.emails(0).deleteVisible, `emails are deletable (manageable)`);

  // Attachment
  page.toolbar.open();
  page.toolbar.addAttachment();
  assert.equal(page.attachments().count, 1, `can insert an attachment uploader`);
  assert.ok(page.attachments(0).editVisible, `attachments are editable (manageable)`);
  assert.ok(page.attachments(0).deleteVisible, `attachments are deletable (manageable)`);

  assert.equal(savecount, 5, `expected number of times to call save`);
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

test('canEdit=false users can send email with permission', function(assert) {
  let task = taskWithBlocks();
  // Set the permissions such that the user can add participants
  let fake = this.container.lookup('service:can');
  fake.allowPermission('add_email_participants', task);

  this.set('fakeSave', function() {});
  this.set('canEdit', false);
  this.set('canManage', false);
  this.set('task', task);
  this.render(template);

  assert.elementFound('.bodypart-display.email .email-send-participants',`emails can always be sent`);
});

test('canEdit=false all fields are disabled', function(assert) {
  let task = taskWithBlocks();
  this.set('fakeSave', function() {});
  this.set('canEdit', false);
  this.set('canManage', false);
  this.set('task', task);
  this.render(template);

  // Checkboxes are disabled
  assert.elementFound('.bodypart-display.checkbox .ember-checkbox[disabled]');

  // Text boxes are not editable
  assert.elementNotFound('.bodypart-display.text .editable[contenteditable]');

  // Emails send in any state
  // If the user cannot add recipients
  assert.elementNotFound('.bodypart-display.email .email-send-participants',`emails can only be sent with permission to add participants`);
});

