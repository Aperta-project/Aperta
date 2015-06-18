import { module, test } from 'qunit';
import urlToHref from 'tahi/lib/url-to-href';

module('UrlToHref');

test('string with http to anchor tags', function(assert) {
  let text           = 'http://tahi.com';
  let result         = urlToHref(text);
  let expectedResult = '<a href="http://tahi.com">http://tahi.com</a>';

  assert.equal(result, expectedResult, 'returns string with anchor tags: ' + expectedResult);
});

test('string with www to anchor tags', function(assert) {
  let text           = 'www.tahi.com';
  let result         = urlToHref(text);
  let expectedResult = '<a href="http://www.tahi.com">www.tahi.com</a>';

  assert.equal(result, expectedResult, 'returns string with anchor tags with www: ' + expectedResult);
});

test('string with anchor to open in new window', function(assert) {
  let text           = 'http://tahi.com';
  let result         = urlToHref(text, true);
  let expectedResult = '<a href="http://tahi.com" target="_blank">http://tahi.com</a>';

  assert.equal(result, expectedResult, 'returns string to open in new window: ' + expectedResult);
});

test('string with with multiple links', function(assert) {
  let text           = 'My favorite site: http://tahi.com. Also, www.tahi-project.org';
  let result         = urlToHref(text);
  let expectedResult = 'My favorite site: <a href="http://tahi.com">http://tahi.com</a>. Also, <a href="http://www.tahi-project.org">www.tahi-project.org</a>';

  assert.equal(result, expectedResult, 'returns string with multiple anchor tags: ' + expectedResult);
});
