import Ember from 'ember';

export default Ember.Helper.helper(function(string1, string2) {
  if(_.isEmpty(string2)){
    return false;
  }
  else {
    return JsDiff.diffChars(string1, string2);
  }
});
