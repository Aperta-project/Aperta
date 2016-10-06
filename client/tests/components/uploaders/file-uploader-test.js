import {
  moduleForComponent,
  test
} from 'ember-qunit';

import hbs from 'htmlbars-inline-precompile';

moduleForComponent('file-uploader',
                   'Integration | Component | file uploader',
                   {integration: true});

test('rejecting improper file types', function(assert) {

  assert.expect(3);
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


test('fires an action on fileuploaddone when url is not provided', function(assert) {
  assert.expect(2);
  this.set('doneStub', function(fileUrl, filename) {
    assert.equal(
      fileUrl,
      'pending/testDir',
      `extracts the first location tag from the response
       and converts %2F escape chars to /`);
    assert.equal(
      filename,
      'testFile',
      `extracts the name of the first file`);
  });
  this.render(hbs`{{file-uploader id="upload-files"
                      done=(action doneStub)}}`
             );

  let resultLocation = $.parseXML('<root><Location>pending%2FtestDir</Location></root>');
  let uploadData = {
    files: [
      {name: 'testFile'}
    ],
    result: resultLocation
  };
  this.$('input').trigger('fileuploaddone', [uploadData]);
});
