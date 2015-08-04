import DS from 'ember-data';

export default DS.Model.extend({
  paper: DS.belongsTo('paper', {async: true}),

  // 'plain' | 'citeproc'
  format: DS.attr('string'),
  // citeproc json or plain text
  content: DS.attr('string'),

  createdAt: DS.attr('date'),
  updatedAt: DS.attr('date'),

  // unique id extracted from citeproc json if available
  getUniqueId() {
    var uuid = null;
    if (this.get('format') === 'citeproc') {
      var data = JSON.parse(this.get('content'));
      uuid = data.DOI || data.ISSN || data.ISBN;
    }
    return uuid || 'bibitem_'+this.get('id');
  },

});
