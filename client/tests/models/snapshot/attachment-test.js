import { test } from 'ember-qunit';
import SnapshotAttachment from 'tahi/models/snapshot/attachment'

module('Unit | snapshot/attachment', {
  needs: []
});

test('has properties extracted', function(assert) {
  const attachment = SnapshotAttachment.create({
    attachment: {
      name: 'some-kind-of-attachment',
      type: 'properties',
      children: [
        { name: 'id', type: 'integer', value: 32 },
        { name: 'caption', type: 'text', value: 'a caption' },
        { name: 'category', type: 'text', value: 'a category' },
        { name: 'file', type: 'text', value: 'zach-overflow.png' },
        { name: 'file_hash', type: 'text', value: 'abc123' },
        { name: 'label', type: 'text', value: 'a label' },
        { name: 'publishable', type: 'boolean', value: true },
        { name: 'status', type: 'text', value: 'done' },
        { name: 'striking_image', type: 'boolean', value: true },
        { name: 'title', type: 'text', value: 'proton.jpg' },
        { name: 'url', type: 'url', value: '/resource_proxy/4pj5bv7E5A9RbJfP7hGi5sds' }
      ]
    }
  });

  assert.equal(attachment.get('id'), 32, 'id was read');
  assert.equal(attachment.get('caption'), 'a caption', 'caption was read');
  assert.equal(attachment.get('category'), 'a category', 'category was read');
  assert.equal(attachment.get('file'), 'zach-overflow.png', 'file was read');
  assert.equal(attachment.get('fileHash'), 'abc123', 'fileHash was read');
  assert.equal(attachment.get('label'), 'a label', 'label was read');
  assert.equal(attachment.get('publishable'), true, 'publishable was read');
  assert.equal(attachment.get('status'), 'done', 'status was read');
  assert.equal(attachment.get('strikingImage'), true, 'strikingImage was read');
  assert.equal(attachment.get('title'), 'proton.jpg', 'title was read');
  assert.equal(attachment.get('url'), '/resource_proxy/4pj5bv7E5A9RbJfP7hGi5sds', 'url was read');
});
