import Ember from 'ember';
import {
  namedComputedProperty,
  diffableTextForQuestion
} from 'tahi/lib/snapshots/snapshot-named-computed-property';

const { computed } = Ember;

const DiffableAuthor = Ember.Object.extend({
  author: null, // this gets passed in
  firstName: namedComputedProperty('author', 'first_name'),
  middleName: namedComputedProperty('author', 'middle_initial'),
  lastName: namedComputedProperty('author', 'last_name'),
  position: namedComputedProperty('author', 'position'),
  title: namedComputedProperty('author', 'title'),
  email: namedComputedProperty('author', 'email'),
  department: namedComputedProperty('author', 'department'),
  affiliation: namedComputedProperty('author', 'affiliation'),
  secondaryAffiliation: namedComputedProperty('author',
                                                 'secondary-affiliation'),

  corresponding: diffableTextForQuestion('author',
                              'author--published_as_corresponding_author'),
  deceased: diffableTextForQuestion('author', 'author--deceased'),

  government: diffableTextForQuestion('author', 'author--government-employee'),

  contributions: computed('author.children.[]', function() {
    var contributions = _.findWhere(
      this.get('author').children,
      {name: 'author--contributions'}
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
