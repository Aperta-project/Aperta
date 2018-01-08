import { module, test } from 'qunit';
import { formatDate, formatFor } from 'tahi/lib/aperta-moment';

module('FormatDate');

test('default formatting', function(assert) {
  let options = {};
  let date    = new Date('February 06, 1990');
  let result  = formatDate(date, options);

  assert.equal(
    result, 'February 6, 1990 00:00',
    'returns a human readable date'
  );
});

test('specify formatting with custom date format constant', function(assert) {
  let options = { format: 'short-date' };
  let result  = formatDate(new Date('February 06, 1990'), options);

  assert.equal(result, 'Feb 6, 1990', 'returns date in a custom format');
});

test('accepts a formatted string as the second arg', function(assert) {
  let result  = formatDate(new Date('February 06, 1990'), 'short-date');

  assert.equal(result, 'Feb 6, 1990', 'returns date in a custom format');
});

test('format only valid dates', function(assert) {
  let options     = {};
  let invalidDate = 'hello world';
  let result      = formatDate(invalidDate, options);

  assert.equal(result, invalidDate, 'returns original value sent');
});

test('get format for custom date constant', function(assert) {
  assert.equal(formatFor('short-date'), 'MMM D, YYYY',        'returns a value from the map');
  assert.equal(formatFor('foo-bar'),    'foo-bar',            'returns arg if not in the map');
  assert.equal(formatFor(),             'MMMM D, YYYY HH:mm', 'returns default if no arg');
});
