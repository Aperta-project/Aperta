// This should be added to any integration test for
// card content that can contain an ident

import { test } from 'ember-qunit';

export default function(template) {
  test(`it has the correct qa ident`, function(assert) {
    assert.expect(1);
    this.render(template);
    let ident = this.get('content.ident');
    // prevent non allowed css characters
    ident = ident.replace(/-?[^_a-zA-Z]+[^_a-zA-Z0-9-]*/g, '_');
    const identClass = `.qa--${ident}`;
    assert.elementFound(identClass);
  });
}
