ETahi.Setups ||= {}
ETahi.Setups.paperWithParticipant = ->
  ef = ETahi.Factory
  journal = ef.createRecord('Journal', id: 1)
  paper = ef.createRecord('Paper', journal_id: journal.id, id: 1)
  litePaper = ef.createLitePaper(paper)
  phase = ef.createPhase(paper)
  task = ef.createTask('Task', paper, phase)
  user = ef.createRecord('User', full_name: 'Some Guy')
  participation = ETahi.Setups.addUserAsParticipant(task, user)

  ef.createPayload('paper').addRecords([journal, paper, litePaper, phase, task, user, participation])

ETahi.Setups.paperWithTask = (taskType, taskAttrs) ->
  ef = ETahi.Factory
  journal = ef.createRecord('Journal', id: 1)
  paper = ef.createRecord('Paper', journal_id: journal.id, editable: true, ETahi.Factory.getNewId('paper'))
  litePaper = ef.createLitePaper(paper)
  phase = ef.createPhase(paper)
  task = ef.createTask(taskType, paper, phase, taskAttrs)

  [paper, task, journal, litePaper, phase]

ETahi.Setups.addUserAsParticipant = (task, user) ->
  ef = ETahi.Factory
  participation = ef.createRecord 'Participation',
    task:
      id: task.id
      type: task.type
    participant_id: user.id

  ef.mergeArrays(task, 'participant_ids', user.id)

  participation
