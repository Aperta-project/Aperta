import { module, test } from 'qunit';
import pluralizeString from 'tahi/lib/pluralize-string';

module('PluralizeString');

test('singular', function(assert) {
  let result = pluralizeString('apple', 1);

  assert.equal(result, 'apple', 'singular version of string');
});

test('plural', function(assert) {
  let result = pluralizeString('apple', 2);

  assert.equal(result, 'apples', 'plural version of string');
});
