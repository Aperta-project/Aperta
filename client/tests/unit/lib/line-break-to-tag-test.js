import { module, test, equal } from 'qunit';
import lineBreakToTag from 'tahi/lib/line-break-to-tag';

module('LineBreakToTag');

test('multiline string', function(assert) {
  let text   = 'A multi\n line\nstring';
  let result = lineBreakToTag(text);

  assert.equal(result, 'A multi<br> line<br>string', 'returns string with break tags');
});
