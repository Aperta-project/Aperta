import Ember from 'ember';

export default Ember.Component.extend({
  snapshot: null,
  classNames: ['snapshot'],

  generalCase: Ember.computed.not("specialCase"),
  specialCase: Ember.computed.or("authors"),

  raw: Ember.computed("snapshot.type", function(){
    let type = this.get("snapshot.type");
    return type == "text" || type === "integer";
  }),

  boolean: Ember.computed("snapshot.type", function(){
    return this.get("snapshot.type") === "boolean";
  }),

  booleanQuestion: Ember.computed("snapshot.value.answer_type", function(){
    return this.get("snapshot.value.answer_type") === "boolean";
  }),

  question: Ember.computed("snapshot.type", function(){
    return this.get("snapshot.type") === "question";
  }),

  authors: Ember.computed("snapshot.name", function(){
    return this.get("snapshot.name") === "authors";
  })

});
