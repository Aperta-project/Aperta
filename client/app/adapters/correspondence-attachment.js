import ApplicationAdapter from 'tahi/adapters/application';

export default ApplicationAdapter.extend({
  buildURL: function(modelName, id, record) {
    let paperId = record.belongsTo('correspondence').belongsTo('paper').id;
    let correspondenceId = record.belongsTo('correspondence').id;
    Ember.assert(`Expected a correspondence.id but didn't find one`, correspondenceId);

    let namespace = this.get('namespace');
    if (namespace) {
      namespace = `/${namespace}`;
    } else {
      namespace = '';
    }

    let url = `${namespace}/papers/${paperId}/correspondence/${correspondenceId}/attachments`;

    if (id) {
      url = `${url}/${id}`;
    }

    return url;
  }
});
