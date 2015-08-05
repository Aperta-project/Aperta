import DS from 'ember-data';

export default DS.Model.extend({
  paper: DS.belongsTo('paper', { async: false }),
  task: DS.belongsTo('task', {
    polymorphic: true,
    inverse: 'commentLooks',
    async: false
  }),
  cardThumbnail: DS.belongsTo('card-thumbnail', {
    inverse: 'commentLooks',
    async: false
  }),
  comment: DS.belongsTo('comment', { async: false }),
  user: DS.belongsTo('user', { async: false })
});
