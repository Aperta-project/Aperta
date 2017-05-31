import Ember from 'ember';

export default Ember.Helper.helper(function(params) {
  if (params[0] === null) {
    return 'Unavailable';    
  } 
  else {
    return params;
  }
});