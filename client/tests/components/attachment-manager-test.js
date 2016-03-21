import Ember from 'ember';
import { test, moduleForComponent } from 'ember-qunit';

moduleForComponent('attachment-manager', 'Component: attachment-manager', {
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

  expect(6);
  component.send('fileAdded', {name: 'hey'});
  assert.equal(component.get('fileUploads.firstObject.file.name'), 'hey', 'File is set');

  component.send('uploadProgress', {
    loaded: 1,
    total: 50,
    files: [{name: 'hey'}]
  });
  assert.equal(component.get('fileUploads.firstObject.dataLoaded'), 1, 'dataLoaded is set on uploadProgress');
  assert.equal(component.get('fileUploads.firstObject.dataTotal'), 50, 'dataTotal is set on uploadProgress');

  component.send('uploadFinished', 'someUrl', {files: [{name: 'hey'}]});

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

  expect(7);

  component.send('fileAdded', {name: 'hey'});
  component.send('fileAdded', {name: 'dude'});
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

  component.send('uploadFinished', 'someUrl', {files: [{name: 'hey'}]});

  assert.equal(1, component.get('fileUploads.length'), 'fileUpload is removed from the array on uploadFinished');
  assert.equal('dude', component.get('fileUploads.firstObject.file.name'), 'correct upload is removed');
});
