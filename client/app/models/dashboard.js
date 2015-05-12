import DS from 'ember-data';

export default DS.Model.extend({
  invitations: DS.hasMany('invitation'),
  papers: DS.hasMany('paper'),
  user: DS.belongsTo('user'),

  totalPaperCount: DS.attr('number'),
  totalPageCount: DS.attr('number')
});
