import Factory from '../helpers/factory';

export function addUserAsParticipant(task, user) {
  let participation = Factory.createRecord('Participation', {
    task: {
      id: task.id,
      type: task.type
    },
    user_id: user.id
  });

  Factory.mergeArrays(task, 'participation_ids', [participation.id]);

  return participation;
}

export function paperWithParticipant() {
  let journal = Factory.createRecord('Journal', {
    id: 1
  });

  let paper = Factory.createRecord('Paper', {
    journal_id: journal.id,
    id: 1
  });

  let litePaper = Factory.createLitePaper(paper);
  let phase     = Factory.createPhase(paper);
  let task      = Factory.createTask('Task', paper, phase);
  let user      = Factory.createRecord('User', {
    full_name: 'Some Guy'
  });

  let participation = addUserAsParticipant(task, user);

  return Factory.createPayload('paper').addRecords([
    journal, paper, litePaper, phase, task, user, participation
  ]);
}

export function paperWithTask(taskType, taskAttrs) {
  let journal = Factory.createRecord('Journal', {
    id: 1
  });

  let paper = Factory.createRecord('Paper', {
    journal_id: journal.id,
    editable: true,
    publishing_state: 'unsubmitted'
  }, Factory.getNewId('paper'));

  let phase = Factory.createPhase(paper);
  let task  = Factory.createTask(taskType, paper, phase, taskAttrs);

  return [paper, task, journal, phase];
}

export function addUserAsCollaborator(paper, user) {
  let collaboration = Factory.createRecord('Collaboration', {
    paper_id: paper.id,
    user_id: user.id
  });

  Factory.mergeArrays(paper, 'collaboration_ids', [collaboration.id]);

  return collaboration;
}

export function paperWithRoles(id, oldRoles) {
  let journal = Factory.createRecord('Journal', {
    id: 1
  });

  let paper = Factory.createRecord('Paper', {
    journal_id: journal.id,
    id: id
  });

  let litePaper = Factory.createLitePaperWithRoles(paper, oldRoles);

  return [paper, journal, litePaper];
}

export function addNestedQuestionsToTask(nestedQuestions, task){
  const ids = nestedQuestions.map( (question) => { return question.id; });
  Factory.mergeArrays(task, 'nested_question_ids', ids);
  nestedQuestions.forEach( (question) => {
    question.owner = { owner_id: task.id, owner_type: "Task" };
  });
  return nestedQuestions;
}

export function addNestedQuestionToTask(nestedQuestion, task){
  const questions = addNestedQuestionsToTask([nestedQuestion], task);
  return questions[0];
}
