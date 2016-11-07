import Ember from 'ember';

export default Ember.Service.extend({
 notifyException: function(exceptionOrTitle, message){
   if (typeof Bugsnag !== 'undefined' && Bugsnag && Bugsnag.notifyException) {
     Bugsnag.notifyException(exceptionOrTitle, message);
   }
   console.error(
     'Bugsnag not available, notifyException called with: ',
     'exceptionOrTitle:',
     exceptionOrTitle,
     'message: ',
     message
   );
 }
});
