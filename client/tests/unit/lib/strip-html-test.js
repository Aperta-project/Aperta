import { module, test } from 'qunit';
import stripHtml from 'tahi/lib/strip-html';

module('StripHtml');

test('strips html - simple case', function(assert) {
  let result = stripHtml('<p>Testing</p>');
  assert.equal(result, 'Testing', 'strips HTML');
});

test('strips html - complex case', function(assert) {
  let result = stripHtml('<p><b>Testing</b> a more <i>complex case</i> is smart</p>');
  assert.equal(result, 'Testing a more complex case is smart', 'strips HTML');
});

test('returns empty string when given undefined value', function(assert) {
  let result = stripHtml(undefined);
  assert.equal(result, '', 'empty string when given undefined');
});

test('returns empty string when given null value', function(assert) {
  let result = stripHtml(null);
  assert.equal(result, '', 'empty string when given null');
});
