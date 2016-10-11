import Ember from 'ember';

export default Ember.Component.extend({
  decision: null,
  readOnly: false,

  competingInterestsLink: Ember.computed(function() {
    const journal = this.get('model.paper.journal.name')
                        .toLowerCase()
                        .replace(' ', '');

    return 'http://journals.plos.org/' + journal + '/s/reviewer-guidelines#loc-competing-interests';
  }),
});
