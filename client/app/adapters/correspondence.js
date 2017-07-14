import Ember from 'ember';
import ApplicationAdapter from 'tahi/adapters/application';

export default ApplicationAdapter.extend({
  buildURL: function(modelName, id, record) {
    let paperId = record.belongsTo('paper').id;
    Ember.assert(`Expected a paper.id but didn't find one`, paperId);

    let namespace = this.get('namespace');
    if (namespace) {
      namespace = `/${namespace}`;
    } else {
      namespace = '';
    }

    let url = `${namespace}/papers/${paperId}/correspondence`;

    if (id) {
      url = `${url}/${id}`;
    }

    return url;
  }
});
