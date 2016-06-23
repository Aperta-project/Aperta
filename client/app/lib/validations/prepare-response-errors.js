import deepJoinArrays from 'tahi/lib/deep-join-arrays';
import deepCamelizeKeys from 'tahi/lib/deep-camelize-keys';
import humanizeStr from 'tahi/lib/humanize';

//errors will look something like [{detail, source: {pointer}}]
function createLegacyErrors(errors) {
  let errorObj = {};
  errors.forEach(({source, detail}) => {
    let errorKey = source.pointer.split('/').pop();
    if (!errorObj[errorKey]) { errorObj[errorKey] = []; }
    errorObj[errorKey].push(detail);
  });

  return errorObj;
}

function formatKey(key, humanize) {
  return humanize ? humanizeStr(key.underscore()) : key.capitalize();
}

/**
  Take response from Rails, camelize keys and join arrays.
  Passing `includeNames: true` or `includeNames: 'humanize'`
  will return the formatted name of the error key with a joined
  list of errors instead of an array.

  @private
  @method prepareResponseErrors
  @param {Object} jsonApiErrors
  @param {Object} options
  @return {Object}
*/

export default function prepareResponseErrors(jsonApiErrors, options) {
  // Instead of passing along rails-style errors we now get a JSON API
  // errors object that we'll temporarily munge into the old style.
  // http://emberjs.com/blog/2015/06/18/ember-data-1-13-released.html#toc_new-errors-api
  // has more detail, as well as http://jsonapi.org/format/#error-objects
  let legacyErrors = createLegacyErrors(jsonApiErrors);

  let errorsObject = deepJoinArrays(deepCamelizeKeys(legacyErrors));

  if (options && options.includeNames) {
    let humanize = options.includeNames === 'humanize';
    Object.keys(errorsObject).forEach((key) =>{
      let keyName = formatKey(key, humanize);
      errorsObject[key] = `${keyName} ${errorsObject[key]}`;
    });
  }
  return errorsObject;
}
