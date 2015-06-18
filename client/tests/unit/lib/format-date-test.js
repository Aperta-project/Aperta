import { module, test } from 'qunit';
import formatDate from 'tahi/lib/format-date';

module('FormatDate');

test('default formatting', function(assert) {
  let helper_options = { hash: {} };
  let date = new Date('February 06, 1990');
  let result = formatDate(date, helper_options);

  assert.equal(result, 'February 6, 1990', 'returns a human readable date');
});

test('specify formatting', function(assert) {
  let helper_options = {
    hash: { format: 'l' }
  };
  let result = formatDate(new Date('February 06, 1990'), helper_options);

  assert.equal(result, '2/6/1990', 'returns date in a custom format');
});

test('format only valid dates', function(assert) {
  let helper_options = { hash: {} };
  let invalidDate    = 'hello world';
  let result         = formatDate(invalidDate, helper_options);

  assert.equal(result, invalidDate, 'returns original value sent');
});
