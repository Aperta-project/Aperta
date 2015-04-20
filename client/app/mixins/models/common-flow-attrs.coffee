`import Ember from 'ember'`
`import DS from 'ember-data'`

CommonFlowAttrs = Ember.Mixin.create
  papers: DS.hasMany('paper')
  tasks: DS.hasMany('card-thumbnail')
  title: DS.attr('string')
  flowId: DS.attr('number')
  taskRoles: DS.attr()

`export default CommonFlowAttrs`
