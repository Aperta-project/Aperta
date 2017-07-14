import { module, test } from 'qunit';
import spacesOutBreaks from 'tahi/lib/space-out-breaks';

module('SpaceOutBreaks');

test('spaces out breaks - simple case', function(assert) {
  let result = spacesOutBreaks('<p>Test<br>ing</p>');
  assert.equal(result, '<p>Test ing</p>', 'spaces out breaks');
});

test('spaces out breaks - complex case', function(assert) {
  let result = spacesOutBreaks('<p><b>Testing</b>  <br> a more <i><br>complex case</i> <br>is smart</p>');
  assert.equal(result, '<p><b>Testing</b> a more <i>complex case</i> is smart</p>', 'spaces out breaks');
});

test('returns empty string when given undefined value', function(assert) {
  let result = spacesOutBreaks(undefined);
  assert.equal(result, '', 'empty string when given undefined');
});

test('returns empty string when given null value', function(assert) {
  let result = spacesOutBreaks(null);
  assert.equal(result, '', 'empty string when given null');
});

test('properly notices hanging brackets', (assert) => {
  let result = spacesOutBreaks(`<p>some are < than<br> some but <br>> than others</p>`);
  assert.equal(result, '<p>some are < than some but > than others</p>');
});
