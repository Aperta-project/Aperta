
import { capitalizeWords } from 'tahi/helpers/capitalize-words';
import { module, test } from 'qunit';

module('Unit | Helper | capitalize words');

// Replace this with your real tests.
test('capitalizes the first letter of every word in string', function(assert) {
  let result = capitalizeWords('some random words');
  assert.ok(result, 'Some Random Words');
});

