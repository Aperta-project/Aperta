import { module, test } from 'qunit';
import formatNumber from 'tahi/lib/format-number';

module('FormatNumber');

test('formatting', function() {
  let number = 1000.01
  let result = formatNumber(number);

  equal(result, '1,000.01', 'returns a human readable number: ' + result);
});

test('no number passed', function() {
  let number = undefined;
  let result = formatNumber(number);

  equal(result, '0', 'returns a zero');
});
