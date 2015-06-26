import DS from 'ember-data';

export default DS.Model.extend({
  paper: DS.belongsTo('paper', {async: true}),

  // 'plain' | 'citeproc'
  type: DS.attr('type'),
  // citeproc json or plain text
  content: DS.attr('string'),

  createdAt: DS.attr('date'),
  updatedAt: DS.attr('date'),

});
