import Ember from 'ember';
import { getNamedComputedProperty, fromProperty, fromQuestion } from 'tahi/mixins/components/snapshot-named-computed-property';

const { computed } = Ember;

const getName = function(properties) {
  if (!properties) {
    return ' ';
  }
  return fromProperty(properties, 'contact_first_name') + ' ' +
         fromProperty(properties, 'contact_middle_name') + ' ' +
         fromProperty(properties, 'contact_last_name');
};

const DiffableAuthor = Ember.Object.extend({
  author: null, // this gets passed in

  groupName: computed('author', function() {
    return fromProperty(this.get('author'), 'position') + '. ' +
      fromProperty(this.get('author'), 'name');
  }),

  contactName: Ember.computed('author', function() {
    return getName(this.get('author'));
  }),
  email: getNamedComputedProperty('author', 'contact_email'),
  initials: getNamedComputedProperty('author', 'initial'),
  contributions: computed('author', function() {
    return this.getContributions(this.get('author'));
  }),

  government: fromQuestion('author', 'group-author--government-employee'),

  getContributions: function(properties) {
    var response = ' ';
    if (!properties) {
      return response;
    }

    var contributions = properties.findBy('name', 'group-author--contributions');
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

