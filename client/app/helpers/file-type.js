import Ember from 'ember';

export default Ember.Helper.helper(function(params) {
  if ( /\.(doc|docx)$/i.test(params) ) {
    return 'fa-file-word-o';
  }
  else if ( /\.(jpe?g|png|gif|bmp)$/i.test(params) ) {
    return 'fa-file-image-o';
  }
  else {
    return 'fa-file-pdf-o';
  }
});
