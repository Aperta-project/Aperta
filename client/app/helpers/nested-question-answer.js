import Ember from 'ember';

export default Ember.Helper.helper(function(params, hash) {
  Ember.assert("Must provide task", hash.task);
  Ember.assert("Must provide ident", hash.ident);

  let question = hash.task.findQuestion(hash.ident);

  if(question){
    let answer = question.answerForOwner(hash.task);
    if(answer){
      return answer.get("value");
    }
  }
  return null;
});
