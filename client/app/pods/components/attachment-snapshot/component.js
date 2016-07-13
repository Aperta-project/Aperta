import Ember from 'ember';

export default Ember.Component.extend({
  attachment1: null,
  attachment2: null,

  fileHashChanged: Ember.computed(
    'attachment1.fileHash',
    'attachment2.fileHash',

    function() {
      var hash1 = this.get('attachment1.fileHash');
      var hash2 = this.get('attachment2.fileHash');
      if (!hash1 || !hash2) {
        return false;
      } else {
        return hash1 !== hash2;
      }
    }
  )

});
