import Ember from 'ember';

// TODO: probably delete this file. it doesn't appear to be used. how do we test to make sure it's dead?

export function findQuestion(params, hash) {
  let [owner, ident] = params;

  let question = owner.get('nestedQuestions').findBy('ident', ident);
  if (hash.answer) {
    return question.answerForOwner(owner);
  } else {
    return question;
  }
}

export default Ember.Helper.helper(findQuestion);
