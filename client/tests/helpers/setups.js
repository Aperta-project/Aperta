/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

import Factory from 'tahi/tests/helpers/factory';

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
  let task      = Factory.createTask('Task', paper, phase, {type: 'AdHocTask'});
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
    publishing_state: 'unsubmitted',
    current_user_roles: ['Creator']
  }, Factory.getNewId('paper'));
  paper.shortDoi = 'test.000' + paper.id;

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

export function addNestedQuestionsToTask(nestedQuestions, task){
  nestedQuestions.forEach( (question) => {
    question.owner = { owner_id: task.id, owner_type: 'Task' };
  });
  return nestedQuestions;
}

export function addNestedQuestionToTask(nestedQuestion, task){
  const questions = addNestedQuestionsToTask([nestedQuestion], task);
  return questions[0];
}
