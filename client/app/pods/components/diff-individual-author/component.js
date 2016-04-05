import Ember from 'ember';

const { computed } = Ember;

const fromProperty = function(properties, name) {
  let property = _.findWhere(properties, { name: name } );
  if (property) {
    return property.value;
  }
  return ' ';
};

const getName = function(properties) {
  if (!properties) {
    return ' ';
  }
  return fromProperty(properties, 'position') + '. ' +
         fromProperty(properties, 'first_name') + ' ' +
         fromProperty(properties, 'middle_initial') + ' ' +
         fromProperty(properties, 'last_name');
};

const authorProperty = function(collectionKey, propertyKey) {
  return Ember.computed(collectionKey + '.[]', function() {
    return fromProperty(this.get(collectionKey), propertyKey);
  });
};

const fromQuestion = function(collectionKey, propertyKey) {
  return Ember.computed(collectionKey + '.[]', function() {
    let properties = this.get(collectionKey);
    let question = _.findWhere(properties, { name: propertyKey });
    if (question && question.value && question.value.answer === true) {
      return question.value.title;
    }
    return ' ';
  });
};

export default Ember.Component.extend({
  viewing: null, //Snapshots are passed in
  comparing: null,

  comparingPosition: authorProperty('comparing.children', 'position'),
  viewingPosition: authorProperty('viewing.children', 'position'),

  viewingName: computed('viewing.children', function() {
    return(getName(this.get('viewing.children')));
  }),

  comparingName: computed('comparing.children', function() {
    return(getName(this.get('comparing.children')));
  }),

  viewingDepartment: authorProperty('viewing.children', 'department'),
  comparingDepartment: authorProperty('comparing.children', 'department'),

  viewingTitle: authorProperty('viewing.children', 'title'),
  comparingTitle: authorProperty('comparing.children', 'title'),

  viewingEmail: authorProperty('viewing.children', 'email'),
  comparingEmail: authorProperty('comparing.children', 'email'),

  viewingAffiliation: authorProperty('viewing.children', 'affiliation'),
  comparingAffiliation: authorProperty('comparing.children', 'affiliation'),

  viewingSecondaryAffiliation: authorProperty('viewing.children',
                                              'secondary-affiliation'),
  comparingSecondaryAffiliation: authorProperty('comparing.children',
                                                'secondary-affiliation'),

  viewingContributions: computed('viewing.children', function() {
    return(this.getContributions(this.get('viewing.children')));
  }),

  comparingContributions: computed('comparing.children', function() {
    return(this.getContributions(this.get('comparing.children')));
  }),

  viewingCorresponding: fromQuestion('viewing.children',
                        'author--published_as_corresponding_author'),
  comparingCorresponding: fromQuestion('comparing.children',
                        'author--published_as_corresponding_author'),

  viewingDeceased: fromQuestion('viewing.children',
                        'author--deceased'),
  comparingDeceased: fromQuestion('comparing.children',
                        'author--deceased'),

  viewingGovernment: fromQuestion('viewing.children',
                        'author--government-employee'),
  comparingGovernment: fromQuestion('comparing.children',
                        'author--government-employee'),

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

