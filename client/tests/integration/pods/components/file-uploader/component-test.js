/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

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
