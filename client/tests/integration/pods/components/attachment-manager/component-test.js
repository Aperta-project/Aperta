import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import Ember from 'ember';
import registerCustomAssertions from 'tahi/tests/helpers/custom-assertions';
import FactoryGuy from 'ember-data-factory-guy';
import { manualSetup, make } from 'ember-data-factory-guy';

moduleForComponent('attachment-manager', 'Integration | Component | attachment-manager', {
  integration: true,
  beforeEach() {
    registerCustomAssertions();
    this.setProperties({
      content: Ember.Object.create({
        allowFileCaptions: true,
        allowMultipleUploads: true,
        label: 'Upload',
        text: 'Please upload a file'
      }),
      answer: Ember.Object.create({ value: null, attachments: [] }),
      acceptedFileTypes: ['png', 'tif'],
      disabled: false
    });
    manualSetup(this.container);
  }
});

let template = hbs`{{attachment-manager
                      filePath="tasks/attachment"
                      attachments=answer.attachments
                      buttonText=content.label
                      description=content.text
                      multiple=content.allowMultipleUploads
                      hasCaption=content.allowFileCaptions
                    }}`;

test(`shows a full attachment manager`, function(assert) {
  this.render(template);
  assert.elementFound('.attachment-manager',
    'element was rendered');
  assert.elementFound('.fileinput-button',
    'has a file input button');
});

test(`displays attachments and has proper action buttons`, function(assert) {
  let attachment = FactoryGuy.make('question-attachment');
  var newReadyIssues = ['incorrect', 'wrong'];

  this.get('answer.attachments').push(attachment);
  this.render(template);

  assert.elementFound('.attachment-item',
    'has an attachment item');
  assert.elementFound('.attachment-item .replace-attachment',
    'has a replacement button');
  assert.elementFound('.attachment-item .delete-attachment',
    'has a replacement button');
  assert.elementNotFound('.validation-error',
    'does not have validation errors by default');

  this.set('answer.attachments.firstObject.readyIssues', newReadyIssues);
  assert.equal($('.validation-error').length, 2,
    'displays all validation errors when present');

  this.set('answer.attachments.firstObject.readyIssues', newReadyIssues.slice(1));
  assert.equal($('.validation-error').length, 1,
    'displays all validation errors when present');
});

test('can cancel processing uploads without passing an action', function(assert){
  let attachment = make('adhoc-attachment', {status: 'processing'});
  assert.expect(3);

  //rather than asserting the correct ajax calls are made, stub the methods
  //that get called on the attachment
  attachment.cancelUpload = () => {
    assert.ok('calls cancelUpload on the attachment');
  };

  attachment.unloadRecord = () => {
    assert.ok('calls unloadRecord on the attachment');
  };
  this.set('filePath', 'test_file_path');
  this.set('answer.attachments', [attachment]);
  this.render(template);

  this.$('.upload-cancel-link').click();

  assert.textPresent('.processing-attachment', 'Upload canceled. Re-upload to try again', 'shows cancel message');
});

test('can delete uploads that have failed during processing without passing an action', function(assert){
  let attachment = make('adhoc-attachment', {status: 'error', filename: 'test file'});
  assert.expect(2);
  //rather than asserting the correct ajax calls are made, stub the methods
  //that get called on the attachment
  attachment.destroyRecord = () => {
    assert.ok('calls destroyRecord');
  };
  this.set('filePath', 'test_file_path');
  this.set('answer.attachments', [attachment]);
  this.render(template);

  this.$('.upload-cancel-button').click();

  assert.textPresent('.processing-attachment .error-message', 'test file', 'shows error message with file name');
});

test('saves the attachment caption when focusing out of the input', function(assert){
  let attachment = make('adhoc-attachment', {status: 'done', filename: 'test file'});
  assert.expect(2);
  //rather than asserting the correct ajax calls are made, stub the methods
  //that get called on the attachment
  attachment.save = () => {
    assert.equal(attachment.get('caption'), 'new caption', 'it sets the new caption on the attachment');
    assert.ok('calls save on the attachment');
  };
  this.set('filePath', 'test_file_path');
  this.set('answer.attachments', [attachment]);
  this.render(template);

  this.$(`input[name='attachment-caption']`).val('new caption').trigger('focusout');

});

let newTemplate = hbs`{{attachment-manager
                      filePath=filePath
                      attachments=attachments
                      cancelUpload=(action cancelUpload)
                      deleteFile=(action deleteFile)}}`;

test('can cancel processing uploads via a cancelUpload action', function(assert){
  let attachment = make('adhoc-attachment', {status: 'processing'});
  assert.expect(2);
  this.set('filePath', 'test_file_path');
  this.set('attachments', [attachment]);
  this.set('deleteFile', function() {});
  this.set('cancelUpload', function() {
    assert.ok(true, 'cancelUpload action is invoked');
  });
  this.render(newTemplate);

  this.$('.upload-cancel-link').click();

  assert.textPresent('.processing-attachment', 'Upload canceled. Re-upload to try again', 'shows cancel message');
});

test('can delete uploads that have failed during processing via the deleteFile action', function(assert){
  let attachment = make('adhoc-attachment', {status: 'error', filename: 'test file'});
  assert.expect(2);
  this.set('filePath', 'test_file_path');
  this.set('attachments', [attachment]);
  this.set('cancelUpload', function() {});
  this.set('deleteFile', function() {
    assert.ok(true, 'deleteFile action is invoked');
  });
  this.render(newTemplate);

  this.$('.upload-cancel-button').click();

  assert.textPresent('.processing-attachment .error-message', 'test file', 'shows error message with file name');
});

