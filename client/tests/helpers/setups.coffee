`import Factory from '../helpers/factory'`

paperWithParticipant = ->
  journal = Factory.createRecord('Journal', id: 1)
  paper = Factory.createRecord('Paper', journal_id: journal.id, id: 1)
  litePaper = Factory.createLitePaper(paper)
  phase = Factory.createPhase(paper)
  task = Factory.createTask('Task', paper, phase)
  user = Factory.createRecord('User', full_name: 'Some Guy')
  participation = addUserAsParticipant(task, user)

  Factory.createPayload('paper').addRecords([journal, paper, litePaper, phase, task, user, participation])

paperWithTask = (taskType, taskAttrs) ->
  journal = Factory.createRecord('Journal', id: 1)
  paper = Factory.createRecord('Paper',
    journal_id: journal.id,
    editable: true,
    publishing_state: 'unsubmitted',
    Factory.getNewId('paper'))
  phase = Factory.createPhase(paper)
  task = Factory.createTask(taskType, paper, phase, taskAttrs)

  [paper, task, journal, phase]

addUserAsParticipant = (task, user) ->
  participation = Factory.createRecord 'Participation',
    task:
      id: task.id
      type: task.type
    user_id: user.id

  Factory.mergeArrays(task, 'participation_ids', [participation.id])

  participation

addUserAsCollaborator = (paper, user) ->
  collaboration = Factory.createRecord 'Collaboration',
    paper_id: paper.id
    user_id: user.id

  Factory.mergeArrays(paper, 'collaboration_ids', [collaboration.id])

  collaboration

paperWithRoles = (id, roles) ->
  journal = Factory.createRecord('Journal', id: 1)
  paper = Factory.createRecord('Paper', journal_id: journal.id, id: id)
  litePaper = Factory.createLitePaperWithRoles(paper, roles)
  [paper, journal, litePaper]

`
export {
  paperWithParticipant,
  paperWithTask,
  paperWithRoles,
  addUserAsParticipant,
  addUserAsCollaborator
}
`
