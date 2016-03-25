import Ember from 'ember';

export default Ember.Component.extend({
  snapshot1: null, //Snapshots are passed in
  snapshot2: null,
  questions: Ember.A(),

  questionsViewing: Ember.computed('snapshot1.contents.children', function() {
    return _.filter(this.get('snapshot1.contents.children'), function(o) {
      return o.type === 'question';
    });
  }),

  questionsComparing: Ember.computed('snapshot2.contents.children', function() {
    return _.filter(this.get('snapshot2.contents.children'), function(o) {
      return o.type === 'question';
    });
  }),

  authorsViewing: Ember.computed('snapshot1.contents.children', function() {
    return _.filter(this.get('snapshot1.contents.children'), function(o) {
      return o.name === 'author' || o.name === 'group-author';
    });
  }),

  authorsComparing: Ember.computed('snapshot2.contents.children', function() {
    return _.filter(this.get('snapshot2.contents.children'), function(o) {
      return o.name === 'author' || o.name === 'group-author';
    });
  }),

  setQuestions: function() {
    var maxLength = Math.max(this.get('questionsViewing').length,
                             this.get('questionsComparing').length);
    for (var i = 0; i < maxLength; i++) {
      var question = {};
      question.viewing = null;
      if (this.get('questionsViewing')[i]) {
        question.viewing = this.get('questionsViewing')[i];
      }
      question.comparing = null;
      if (this.get('questionsComparing')[i]) {
        question.comparing = this.get('questionsComparing')[i];
      }
      this.get('questions')[i] = question;
    }
  },

  init: function() {
    this._super(...arguments);
    this.setQuestions();
    debugger;
  }
});
