import Ember from 'ember';

const TYPES = {
  'presence': function(value) {
    const fail = Ember.isEmpty(value);
    return fail ? 'can\'t be blank' : false;
  }
};

export default {
  validate(value, types) {
    return types.map(function(type) {
      return TYPES[type](value);
    }).filter(function(value) {
      return value;
    });
  }
};
