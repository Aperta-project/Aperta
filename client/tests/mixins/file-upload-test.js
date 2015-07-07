import { module, test } from 'qunit';
import Ember from 'ember';
import FileUploadMixin from 'tahi/mixins/file-upload';

module('FileUploadMixin', {
  setup: function() {
    this.cntrl = Ember.Object.createWithMixins(FileUploadMixin, {});
  }
});

test('with data key delays progress bar', function(assert) {
  this.cntrl.uploads = [{file: {name: 'yeti.jpg'}}];
  var data = { figure: 'some figure' };
  this.cntrl.uploadFinished(data, 'yeti.jpg');
  var uploads = this.cntrl.uploads;
  assert.equal(uploads.length, 1);
});


test('without data keys skips progress bar', function(assert) {
  this.cntrl.uploads = [{file: {name: 'yeti.jpg'}}];
  var data = {};
  this.cntrl.uploadFinished(data, 'yeti.jpg');
  var uploads = this.cntrl.uploads;
  assert.equal(uploads.length, 0);
});
