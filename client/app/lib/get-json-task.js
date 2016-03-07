import { task } from 'ember-concurrency';

export default task(function * (url, data) {
  let xhr;
  try {
    xhr = Ember.$.getJSON(url, data);
    const result = yield xhr.promise();
    return result;
  } finally {
    xhr.abort();
  }
});
