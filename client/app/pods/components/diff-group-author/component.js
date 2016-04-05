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
  console.log(properties);
  return fromProperty(properties, 'contact_first_name') + ' ' +
         fromProperty(properties, 'contact_middle_name') + ' ' +
         fromProperty(properties, 'contact_last_name');
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

  viewingName: computed('viewing.children', function() {
    return fromProperty(this.get('viewing.children'), 'position') + '. ' +
           fromProperty(this.get('viewing.children'), 'name');
  }),

  comparingName: computed('comparing.children', function() {
    return fromProperty(this.get('comparing.children'), 'position') + '. ' +
           fromProperty(this.get('comparing.children'), 'name');
  }),

  viewingInitials: authorProperty('viewing.children', 'initial'),
  comparingInitials: authorProperty('comparing.children', 'initial'),

  comparingPosition: authorProperty('comparing.children', 'position'),
  viewingPosition: authorProperty('viewing.children', 'position'),

  viewingContactName: computed('viewing.children', function() {
    return(getName(this.get('viewing.children')));
  }),

  comparingContactName: computed('comparing.children', function() {
    return(getName(this.get('comparing.children')));
  }),

  viewingEmail: authorProperty('viewing.children', 'contact_email'),
  comparingEmail: authorProperty('comparing.children', 'contact_email'),

  viewingGovernment: fromQuestion('viewing.children',
                        'group-author--government-employee'),
  comparingGovernment: fromQuestion('comparing.children',
                        'group-author--government-employee'),

  viewingContributions: computed('viewing.children', function() {
    return(this.getContributions(this.get('viewing.children')));
  }),

  comparingContributions: computed('comparing.children', function() {
    return(this.getContributions(this.get('comparing.children')));
  }),

  getContributions: function(properties) {
    var response = ' ';
    var contributions = this.fromProperty(properties,
                                          'group-author--contributions');
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

