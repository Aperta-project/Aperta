// This should be added to any integration test for
// card content that can contain an ident

import { test } from 'ember-qunit';

export default function(template) {
  test(`it has the correct qa ident`, function(assert) {
    assert.expect(1);
    this.render(template);
    const ident = this.get('content.ident');
    const identClass = `.card-content.qa--${ident}`;
    assert.elementFound(identClass);
  });
}
