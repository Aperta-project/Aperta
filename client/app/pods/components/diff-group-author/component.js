import Ember from 'ember';
import {
  namedComputedProperty,
  diffableTextForQuestion
} from 'tahi/mixins/components/snapshot-named-computed-property';

const { computed } = Ember;

const DiffableAuthor = Ember.Object.extend({
  author: null, // this gets passed in
  position: namedComputedProperty('author', 'position'),
  name: namedComputedProperty('author', 'name'),
  contactFirstName: namedComputedProperty('author', 'contact_first_name'),
  contactMiddleName: namedComputedProperty('author', 'contact_middle_name'),
  contactLastName: namedComputedProperty('author', 'contact_last_name'),

  email: namedComputedProperty('author', 'contact_email'),
  initials: namedComputedProperty('author', 'initial'),

  government: diffableTextForQuestion(
    'author',
    'group-author--government-employee'),

  contributions: computed('author.children.[]', function() {
    var contributions = _.findWhere(
      this.get('author').children,
      {name: 'group-author--contributions'}
    ) || [];

    var selectedNames = _.compact(_.map(
      contributions.children,
      function(contribution) {
        if (!contribution.value.answer) { return null; }
        return contribution.value.title;
      }
    ));

    return selectedNames.join(', ');
  })
});

export default Ember.Component.extend({
  viewingAuthor: null, //Snapshots are passed in
  comparingAuthor: null,

  viewing: computed('viewingAuthor', function() {
    return DiffableAuthor.create(
      { author: this.get('viewingAuthor') } );
  }),

  comparing: computed('comparingAuthor', function() {
    if (!this.get('comparingAuthor')) { return {}; }
    return DiffableAuthor.create(
      { author: this.get('comparingAuthor') } );
  })
});
