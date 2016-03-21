import Ember from 'ember';
import { test, moduleForComponent } from 'ember-qunit';

moduleForComponent('attachment-manager', 'Component: attachment-manager', {
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
  component.send('fileAdded', 'hey');
  assert.equal(component.get('fileUpload.file'), 'hey', 'File is set');

  component.send('uploadProgress', {loaded: 1, total: 50});
  assert.equal(component.get('fileUpload.dataLoaded'), 1, 'dataLoaded is set on uploadProgress');
  assert.equal(component.get('fileUpload.dataTotal'), 50, 'dataTotal is set on uploadProgress');

  component.send('uploadFinished', 'someUrl');
  assert.equal(null, component.get('fileUpload'), 'fileUpload is set to null on uploadFinished');
});
