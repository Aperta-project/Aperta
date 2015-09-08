import Ember from 'ember';

export default Ember.Component.extend({
  ident: null,

  inQuestions: [],

  question: Ember.computed(function(){
    let found = _.detect(this.inQuestions, (q) => {
      if(q.ident === this.ident){
        return q;
      }
    });
    return found;
  })

});
