import ApplicationAdapter from 'tahi/adapters/application';

export default ApplicationAdapter.extend({
  urlForQueryRecord(query) {
    return `/api/papers/${query.shortDoi}`;
  }
});
