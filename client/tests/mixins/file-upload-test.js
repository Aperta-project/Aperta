import { module, test } from 'qunit';
import Ember from 'ember';
import FileUploadMixin from 'tahi/mixins/file-upload';

module('FileUploadMixin', {
  beforeEach() {
    this.cntrl = Ember.Object.createWithMixins(FileUploadMixin, {});
  }
});

test('with data key delays progress bar', function(assert) {
  this.cntrl.uploads = [{file: {name: 'yeti.jpg'}}];
  let data = { figure: 'some figure' };
  this.cntrl.uploadFinished(data, 'yeti.jpg');
  let uploads = this.cntrl.uploads;
  assert.equal(uploads.length, 1);
});


test('without data keys skips progress bar', function(assert) {
  this.cntrl.uploads = [{file: {name: 'yeti.jpg'}}];
  let data = {};
  this.cntrl.uploadFinished(data, 'yeti.jpg');
  let uploads = this.cntrl.uploads;
  assert.equal(uploads.length, 0);
});

// it seems like this file should have a LOOT more tests in it
