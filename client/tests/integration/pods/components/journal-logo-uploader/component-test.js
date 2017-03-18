import { moduleForComponent, test } from 'ember-qunit';
import hbs from 'htmlbars-inline-precompile';

moduleForComponent('journal-logo-uploader', 'Integration | Component | journal logo uploader', {
  integration: true
});

test('it renders a logo placeholder', function(assert) {
  this.render(hbs`{{journal-logo-uploader logoUrl=null}}`);
  assert.elementFound('.journal-logo-thumbnail-placeholder');
});

test('it renders the logo image', function(assert) {
  this.set('logoUrl', 'http://example.com/image.png');

  this.render(hbs`{{journal-logo-uploader logoUrl=logoUrl}}`);
  assert.elementFound('img.journal-logo-thumbnail');
});

test('it renders the s3 upload button', function(assert) {
  this.render(hbs`{{journal-logo-uploader}}`);
  assert.elementFound('#upload-journal-logo-button');
});
