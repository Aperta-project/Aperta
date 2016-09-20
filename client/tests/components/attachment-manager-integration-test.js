import { test, moduleForComponent } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';
import { manualSetup, make } from 'ember-data-factory-guy';
import registerCustomAssertions from '../helpers/custom-assertions';

moduleForComponent('attachment-manager', 'Integration | Component | attachment manager', {
  integration: true,
  beforeEach() {
    registerCustomAssertions();
    manualSetup(this.container);
  }
});

let template = hbs`{{attachment-manager
                      filePath=filePath
                      attachments=attachments
                      cancelUpload=(action cancelUpload)
                      deleteFile=(action deleteFile)}}`;
test('can cancel processing uploads', function(assert){
  let attachment = make('adhoc-attachment', {status: 'processing'});
  assert.expect(2);
  this.set('filePath', 'test_file_path');
  this.set('attachments', [attachment]);
  this.set('cancelUpload', function() {
    assert.ok(true, 'cancelUpload action is invoked');
  });
  this.render(template);

  this.$('.upload-cancel-button').click();

  assert.textPresent('.processing-attachment', 'Upload canceled. Re-upload to try again', 'shows cancel message');
});

test('can delete uploads that have failed during processing', function(assert){
  let attachment = make('adhoc-attachment', {status: 'error', filename: 'test file'});
  assert.expect(2);
  this.set('filePath', 'test_file_path');
  this.set('attachments', [attachment]);
  this.set('deleteFile', function() {
    assert.ok(true, 'deleteFile action is invoked');
  });
  this.render(template);

  this.$('.upload-cancel-button').click();

  assert.textPresent('.processing-attachment .error-message', 'test file', 'shows error message with file name');
});
