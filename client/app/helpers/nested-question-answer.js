import Ember from 'ember';

export default Ember.Helper.helper(function(params, hash) {
  Ember.assert("Must provide owner", hash.owner);
  Ember.assert("Must provide ident", hash.ident);

  let answer = hash.owner.answerForQuestion(hash.ident);
  if(answer){
    return answer.get("value");
  } else {
    return null;
  }
});
