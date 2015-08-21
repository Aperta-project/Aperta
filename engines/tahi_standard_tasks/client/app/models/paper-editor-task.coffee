`import DS from 'ember-data'`
`import Task from 'tahi/models/task'`

PaperEditorTask = Task.extend
  editor: DS.belongsTo('user')
  invitation: DS.belongsTo('invitation')
  letter: DS.attr('string')
  invitationTemplate: (->
    JSON.parse(@get('letter'))
  ).property 'letter'

`export default PaperEditorTask`
