import { breakToTag } from 'tahi/helpers/break-to-tag';

module('Unit | Helper | break-to-tag');

test('converts line returns to break tags', function(assert) {
  const string = 'Some\ntext';
  const result = breakToTag(string);
  assert.equal(result, 'Some<br>text', 'break tag found')
});
