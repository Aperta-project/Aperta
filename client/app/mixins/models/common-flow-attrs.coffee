`import Ember from 'ember'`
`import DS from 'ember-data'`

CommonFlowAttrs = Ember.Mixin.create
  litePapers: DS.hasMany('litePaper')
  tasks: DS.hasMany('cardThumbnail')
  title: DS.attr('string')
  flowId: DS.attr('number')
  taskRoles: DS.attr()

`export default CommonFlowAttrs`
