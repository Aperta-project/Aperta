import ApplicationAdapter from 'tahi/adapters/application';
import DS from 'ember-data';

export default ApplicationAdapter.extend(DS.BuildURLMixin, {
  urlForQueryRecord() {
    return '/api/find_card';
  }
});
