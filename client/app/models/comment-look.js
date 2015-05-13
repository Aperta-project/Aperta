import DS from 'ember-data';

export default DS.Model.extend({
  paper: DS.belongsTo('paper'),
  task: DS.belongsTo('task', { polymorphic: true, inverse: 'commentLooks' }),
  cardThumbnail: DS.belongsTo('card-thumbnail', { inverse: 'commentLooks' }),
  comment: DS.belongsTo('comment'),
  user: DS.belongsTo('user')
});
