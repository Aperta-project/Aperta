import {
  moduleForComponent,
  test
} from 'ember-qunit';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent('file-uploader',
                   'Component: file-uploader',
                   {integration: true});

test('rejecting improper file types', function(assert) {

  expect(3);
  let fakeData = {files: [{name: 'badFile.png'}]};

  this.set('failedAddStub', function(errorMessage, {fileName, acceptedFileTypes}) {
    assert.ok(errorMessage, 'it passes some kind of error text');
    assert.equal(fileName, 'badFile.png', 'it returns the name of the failed file');
    assert.equal(acceptedFileTypes, '.docx,.doc', 'it returns the file types from the accept attribute');

  });
  this.render(hbs`{{file-uploader id="upload-files"
                      railsMethod="PUT"
                      accept=".docx,.doc"
                      start="uploadStarted"
                      progress="uploadProgress"
                      done="uploadFinished"
                      addingFileFailed=(action failedAddStub)
                      error="uploadError"
                      filePrefix="paper/manuscript"
                      url=manuscriptUploadUrl
                      disabled=isNotEditable}}
                      `);


  this.$('input').trigger('fileuploadadd', [fakeData]);

});
