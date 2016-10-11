/**
 * Since questions aren't related to their owner
 * we need to use a helper function to setup that side
 * of the relationship after using factoryguy to make
 * the question itself.  These convencience functions will
 * put the models into the store and also return them in an
 * object
 *
 * If using in a component integration test, be sure to call
 * FactoryGuy.manualSetup() with the test container
 * Before invoking these functions, or `make` will fail
 **/
import { make } from 'ember-data-factory-guy';

export function createQuestionForOwner(questionAttrs) {
  let { owner } = questionAttrs;
  let question = make('nested-question', questionAttrs);

  owner.get('nestedQuestions').addObject(question);
  return { question };
}

export function createQuestionAndAnswerForOwner(questionAttrs, answerValue) {
  let { owner, ident } = questionAttrs;
  let answer = make('nested-question-answer', {value: answerValue, owner});
  let question = make('nested-question', {
    ident,
    owner,
    answers: [answer]
  });

  owner.get('nestedQuestions').addObject(question);
  return { question, answer };
}
