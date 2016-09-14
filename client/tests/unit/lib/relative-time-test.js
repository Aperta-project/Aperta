import { module, test } from 'qunit';
import relativeTime from 'tahi/lib/relative-time';

module('RelativeTime');

let now = 'September 13, 2016 13:17:56 UTC';

test('3 days ago, beginning of day', function(assert) {
  const startOfDay = moment(now).utc().startOf('day');
  const endOfDay = moment(now).utc().endOf('day');

  var date = new Date('September 10, 2016 00:00:09 UTC');

  assert.equal(relativeTime(date, startOfDay), '3 days ago', 'returns a human readable string for how many days ago a date was');
  assert.equal(relativeTime(date, endOfDay), '3 days ago', 'returns a human readable string for how many days ago a date was');
});

test('3 days ago, noon time', function(assert) {
  const startOfDay = moment(now).utc().startOf('day');
  const endOfDay = moment(now).utc().endOf('day');

  var date = new Date('September 10, 2016 12:00:00 UTC');

  assert.equal(relativeTime(date, startOfDay), '3 days ago', 'returns a human readable string for how many days ago a date was');
  assert.equal(relativeTime(date, endOfDay), '3 days ago', 'returns a human readable string for how many days ago a date was');
});

test('3 days ago, end of day', function(assert) {
  const startOfDay = moment(now).utc().startOf('day');
  const endOfDay = moment(now).utc().endOf('day');

  var date = new Date('September 10, 2016 23:59:59 UTC');

  assert.equal(relativeTime(date, startOfDay), '3 days ago', 'returns a human readable string for how many days ago a date was');
  assert.equal(relativeTime(date, endOfDay), '3 days ago', 'returns a human readable string for how many days ago a date was');
});

test('61 days ago, beginning of day', function(assert) {
  const startOfDay = moment(now).utc().startOf('day');
  const endOfDay = moment(now).utc().endOf('day');

  var date = new Date('July 14, 2016 00:00:09 UTC');

  assert.equal(relativeTime(date, startOfDay), '61 days ago', 'returns a human readable string for how many days ago a date was');
  assert.equal(relativeTime(date, endOfDay), '61 days ago', 'returns a human readable string for how many days ago a date was');
});

test('61 days ago, noon time', function(assert) {
  const startOfDay = moment(now).utc().startOf('day');
  const endOfDay = moment(now).utc().endOf('day');

  var date = new Date('July 14, 2016 12:00:00 UTC');

  assert.equal(relativeTime(date, startOfDay), '61 days ago', 'returns a human readable string for how many days ago a date was');
  assert.equal(relativeTime(date, endOfDay), '61 days ago', 'returns a human readable string for how many days ago a date was');
});

test('61 days ago, end of day', function(assert) {
  const startOfDay = moment(now).utc().startOf('day');
  const endOfDay = moment(now).utc().endOf('day');

  var date = new Date('July 14, 2016 23:59:59 UTC');

  assert.equal(relativeTime(date, startOfDay), '61 days ago', 'returns a human readable string for how many days ago a date was');
  assert.equal(relativeTime(date, endOfDay), '61 days ago', 'returns a human readable string for how many days ago a date was');
});
