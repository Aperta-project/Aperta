import Ember from 'ember';

export default Ember.Component.extend({
  tagName: "span",
  owner: null,
  ident: null,

  yesLabel: null,
  noLabel: null,

  answer: Ember.computed(function(){
    let owner = this.get("owner");
    Ember.assert("Must provide owner", owner);

    let ident = this.get("ident");
    Ember.assert("Must provide ident", ident);

    let answer = owner.answerForQuestion(ident);
    if(answer){
      return answer;
    } else {
      return null;
    }
  }),

  answerText: Ember.computed("answer", function(){
    let answer = this.get("answer");
    let yesLabel = this.get("yesLabel");
    let noLabel = this.get("noLabel");

    if(answer){
      let value = answer.get("value");
      if(yesLabel && value){
        return yesLabel;
      } else if(noLabel && !value){
        return noLabel;
      } else {
        return value;
      }
    } else {
      return "";
    }
  })
});
