import Ember from 'ember';

const { computed } = Ember;
const { filterBy, union, sort } = computed;

const getName = function(properties) {
  if (!properties) {
    return ' ';
  }
  return fromProperty(properties, 'first_name').value + ' ' +
         fromProperty(properties, 'middle_initial').value + ' ' +
         fromProperty(properties, 'last_name').value;
};

const fromProperty = function(properties, name) {
  return _.findWhere(properties, { name: name } );
};

const authorName = function(author) {
  return Ember.computed(author, function () {
    return(getName(this.get(author)));
  })
};

const authorProperty = function(collectionKey, propertyKey) {
  return Ember.computed(collectionKey + '.[]', function() {
    return this.get(collectionKey).findBy('name', propertyKey).value || ' ';
  });
};

export default Ember.Component.extend({
  viewing: null, //Snapshots are passed in
  comparing: null,

  comparingPosition: authorProperty('comparing.children', 'position'),
  viewingPosition: authorProperty('viewing.children', 'position'),

  viewingName: computed('viewing.children', function() {
    console.log('properties', this.getName(this.get('viewing.children')));
    return(this.getName(this.get('viewing.children')));
  }),

  comparingName: computed('comparing.children', function() {
    return(this.getName(this.get('comparing.children')));
  }),

  viewingContributions: computed('viewing.children', function() {
    return(this.getContributions(this.get('viewing.children')));
  }),

  comparingContributions: computed('comparing.children', function() {
    return(this.getContributions(this.get('comparing.children')));
  }),

  getName: function(properties) {
    if (!properties) {
      return ' ';
    }
    return this.fromProperty(properties, 'first_name').value + ' ' +
           this.fromProperty(properties, 'middle_initial').value + ' ' +
           this.fromProperty(properties, 'last_name').value;
  },

  getContributions: function(properties) {
    var response = ' ';
    var contributions = this.fromProperty(properties, 'author--contributions');
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
  },

  fromProperty: function(properties, name) {
    return _.findWhere(properties, { name: name } );
  }
});

