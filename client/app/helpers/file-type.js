import Ember from 'ember';

export default Ember.Helper.helper(function(params) {
  if ( /\.(doc|docx)$/i.test(params) ) {
    return 'fa-file-word-o';
  }
  else {
    return 'fa-file-pdf-o';
  }
});
