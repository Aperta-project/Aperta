import Ember from 'ember';
import ApplicationAdapter from 'tahi/pods/application/adapter';

export default ApplicationAdapter.extend({
  buildURL: function(modelName, id, record) {
    let paper = record.belongsTo('paper');
    let paperId = Ember.isPresent(paper)? paper.id : null;

    Ember.assert(`Expected a paper ID or correspondence ID but didn't find one`, paperId || id);

    let namespace = this.get('namespace');
    if (namespace) {
      namespace = `/${namespace}`;
    } else {
      namespace = '';
    }

    let url = paper ? `${namespace}/papers/${paperId}/correspondence` : `${namespace}/correspondence`;

    if (id) {
      url = `${url}/${id}`;
    }

    return url;
  }
});
