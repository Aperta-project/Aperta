import Ember from 'ember';
import ApplicationAdapter from 'tahi/pods/application/adapter';

export default ApplicationAdapter.extend({
  buildURLForModel(model) {
    let shortDoi = Ember.get(model, 'shortDoi');
    return `/api/papers/${shortDoi}`;
  },

  query(store, type, query) {
    let url = this.buildURLForModel(query);
    return this.ajax(url, 'GET');
  }
});
