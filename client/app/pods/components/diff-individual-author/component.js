import Ember from 'ember';
import {
  namedComputedProperty,
  fromProperty,
  diffableTextForQuestion
} from 'tahi/mixins/components/snapshot-named-computed-property';

const { computed } = Ember;

const getName = function(properties) {
  if (!properties) {
    return ' ';
  }
  return fromProperty(properties, 'position') + '. ' +
         fromProperty(properties, 'first_name') + ' ' +
         fromProperty(properties, 'middle_initial') + ' ' +
         fromProperty(properties, 'last_name');
};

const DiffableAuthor = Ember.Object.extend({
  author: null, // this gets passed in
  authorName: Ember.computed('author', function() {
    return getName(this.get('author'));
  }),
  title: namedComputedProperty('author', 'title'),
  email: namedComputedProperty('author', 'email'),
  department: namedComputedProperty('author', 'department'),
  affiliation: namedComputedProperty('author', 'affiliation'),
  secondaryAffiliation: namedComputedProperty('author',
                                                 'secondary-affiliation'),
  contributions: computed('author', function() {
    return this.getContributions(this.get('author'));
  }),

  corresponding: diffableTextForQuestion('author',
                              'author--published_as_corresponding_author'),
  deceased: diffableTextForQuestion('author', 'author--deceased'),

  government: diffableTextForQuestion('author', 'author--government-employee'),

  getContributions: function(properties) {
    var response = ' ';
    if (!properties) {
      return response;
    }

    var contributions = properties.findBy('name', 'author--contributions');
    if (contributions) {
      _.each(contributions.children, function(contribution) {
        if (contribution.value.answer) {
          response += contribution.value.title + ', ';
        }
      });
      if (response.endsWith(', ')) {
        response = response.substring(0, response.length - 2);
      }
    }
    return response;
  }
});

export default Ember.Component.extend({
  viewingAuthor: null, //Snapshots are passed in
  comparingAuthor: null,

  viewing: computed('viewingAuthor', function() {
    return DiffableAuthor.create(
      { author: this.get('viewingAuthor.children') } );
  }),

  comparing: computed('comparingAuthor', function() {
    return DiffableAuthor.create(
      { author: this.get('comparingAuthor.children') } );
  }),
});
