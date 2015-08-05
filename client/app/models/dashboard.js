import DS from 'ember-data';

export default DS.Model.extend({
  invitations: DS.hasMany('invitation', { async: false }),
  papers: DS.hasMany('paper', { async: false }),
  user: DS.belongsTo('user', { async: false }),

  totalPaperCount: DS.attr('number'),
  totalPageCount: DS.attr('number')
});
