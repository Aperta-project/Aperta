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

let template = hbs`{{attachment-manager filePath=filePath attachments=testAttachments cancelUpload=(action cancelUpload)}}`;
test('can cancel processing uploads', function(assert){
  let attachment = make('adhoc-attachment', {status: 'processing'});
  this.set('filePath', 'test_file_path');
  this.set('attachments', [attachment]);
  this.set('cancelUpload', function() {
    assert.ok(true, 'cancelUpload action is invoked');
  });
  this.render(template);

  this.$('.upload-cancel-button').click();

  assert.textPresent('.progress-text','Upload canceled. Re-upload to try again', 'shows cancel message');
});
