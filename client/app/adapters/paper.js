import ApplicationAdapter from 'tahi/adapters/application';

export default ApplicationAdapter.extend({
  query(store, type, query) {
    return this.ajax(`/api/papers/${query.shortDoi}`, 'GET');
  }
});
