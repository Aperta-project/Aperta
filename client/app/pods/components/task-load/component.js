import Ember from 'ember';

export default Ember.Component.extend({
  dataLoading: false,

  init() {
    this._super(...arguments);
    this.set('dataLoading', true);

    Ember.RSVP.all([
      this.get('task').get('nestedQuestions'),
      this.get('task').get('nestedQuestionAnswers'),
      this.get('task').reload()
    ]).then(()=> {
      this.set('dataLoading', false);
    });
  }
});
