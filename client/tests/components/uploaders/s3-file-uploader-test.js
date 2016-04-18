import {
  moduleForComponent,
  test
} from 'ember-qunit';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent('s3-file-uploader',
                   'Integration | Component | s3 file uploader',
                   {integration: true});
test('rejecting improper file types', function(assert) {

  expect(3);
  let fakeData = {files: [{name: 'badFile.png'}]};

  this.set('failedAddStub', function(errorMessage, {fileName, acceptedFileTypes}) {
    assert.ok(errorMessage, 'it passes some kind of error text');
    assert.equal(fileName, 'badFile.png', 'it returns the name of the failed file');
    assert.equal(acceptedFileTypes, '.docx,.doc', 'it returns the file types from the accept attribute');

  });
  this.render(hbs`{{s3-file-uploader elementId="upload-files"
                       accept=".docx,.doc"
                       validateFileTypes=true
                       filePath="paper/manuscript"
                       addingFileFailed=(action failedAddStub)}}
                       `);



  this.$('input').trigger('fileuploadadd', [fakeData]);

});
