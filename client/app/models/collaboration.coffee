`import DS from 'ember-data'`

Collaboration = DS.Model.extend
  paper: DS.belongsTo('paper')
  user:  DS.belongsTo('user')

`export default Collaboration`
