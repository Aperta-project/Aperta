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

import { test, moduleForComponent } from 'ember-qunit';

moduleForComponent('attachment-manager', 'Unit | Component | attachment manager', {
  unit: true
});

test('uploading a single file works', function(assert) {
  const finishedStub = (url, file) => {
    assert.ok(url, 'uploadFinished is called with a url');
    assert.ok(file, 'uploadFinished is called with a file');
  };

  const component = this.subject({
    filePath: '/some-path',
    attrs: { uploadFinished: finishedStub }
  });

  assert.expect(6);
  component.send('fileAdded', {files: [{name: 'hey'}]});
  assert.equal(component.get('fileUploads.firstObject.file.name'), 'hey', 'File is set');

  component.send('uploadProgress', {
    loaded: 1,
    total: 50,
    files: [{name: 'hey'}]
  });
  assert.equal(component.get('fileUploads.firstObject.dataLoaded'), 1, 'dataLoaded is set on uploadProgress');
  assert.equal(component.get('fileUploads.firstObject.dataTotal'), 50, 'dataTotal is set on uploadProgress');

  component.send('uploadFinished', 'someUrl', 'hey', {files: [{name: 'hey'}]});

  assert.equal(0, component.get('fileUploads.length'), 'fileUpload is removed from the array on uploadFinished');
});

test('uploading multiple files correctly maintains state', function(assert) {
  const finishedStub = (url, file) => {
    assert.equal('hey', file.name, 'uploadFinished is called with the correct file');
  };

  const component = this.subject({
    filePath: '/some-path',
    attrs: { uploadFinished: finishedStub }
  });

  assert.expect(7);

  component.send('fileAdded', {files: [{name: 'hey'}]});
  component.send('fileAdded', {files: [{name: 'dude'}]});
  assert.equal(component.get('fileUploads.firstObject.file.name'), 'hey', 'File is set');
  assert.equal(component.get('fileUploads.lastObject.file.name'), 'dude', 'File is set');

  component.send('uploadProgress', {
    loaded: 2,
    total: 20,
    files: [{name: 'dude'}]
  });
  component.send('uploadProgress', {
    loaded: 1,
    total: 50,
    files: [{name: 'hey'}]
  });

  assert.equal(component.get('fileUploads.firstObject.dataTotal'), 50, 'uploadProgress for the first file');
  assert.equal(component.get('fileUploads.lastObject.dataTotal'), 20, 'uploadProgress for the second file');

  component.send('uploadFinished', 'someUrl', 'hey', {files: [{name: 'hey'}]});

  assert.equal(1, component.get('fileUploads.length'), 'fileUpload is removed from the array on uploadFinished');
  assert.equal('dude', component.get('fileUploads.firstObject.file.name'), 'correct upload is removed');
});
