import ApplicationAdapter from 'tahi/adapters/application';

export default ApplicationAdapter.extend({
  queryRecord(store, type, query) {
    return this.ajax(`/api/papers/${query.shortDoi}`, 'GET');
  }
});
