import Ember from 'ember';

export default Ember.Component.extend({
  decision: null,
  readOnly: false,

  competingInterestsLink: Ember.computed('model.task.paper.journal.name', function() {
    const name = this.get('model.task.paper.journal.name');
    if (name) {
      return `http://journals.plos.org/${name.toLowerCase().replace(' ', '')}/s/reviewer-guidelines#loc-competing-interests`;
    } else {
      return 'http://journals.plos.org/';
    }
  }),
});
