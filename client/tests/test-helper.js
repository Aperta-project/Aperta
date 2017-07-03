import resolver from './helpers/resolver';
import {
  setResolver
} from 'ember-qunit';

setResolver(resolver);

import {
  addModuleExcludeMatcher
} from 'ember-cli-test-loader/test-support/index';

// http://werxltd.com/wp/2010/05/13/javascript-implementation-of-javas-string-hashcode-method/
function hashString(str) {
  var hash = 0, i, chr;
  if (str.length === 0) return hash;
  for (i = 0; i < str.length; i++) {
    chr = str.charCodeAt(i);
    hash = ((hash << 5) - hash) + chr;
    hash |= 0;
  }
  return Math.abs(hash); // We need a positive integer
}

// Parallelize for circleCI
if (QUnit.urlParams.workerIndex && QUnit.urlParams.numWorkers) {
  // Exclude all but the tests where the hash of the module name modulo the
  // number of workers equals the worker index.
  addModuleExcludeMatcher(function(moduleName) {
    return ((hashString(moduleName) % parseInt(QUnit.urlParams.numWorkers))
            !== parseInt(QUnit.urlParams.workerIndex));
  });
}
