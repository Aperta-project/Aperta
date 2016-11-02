export default {
  initialize(instance) {
     const bugsnagService = Ember.Object.extend({
       notifyException: function(exceptionOrTitle, message){
         if (typeof Bugsnag !== 'undefined' && Bugsnag && Bugsnag.notifyException) {
           Bugsnag.notifyException(exceptionOrTitle, message);
         } else {
           let log = console.error;
           log(
             'Bugsnag not available, notifyException called with: ',
             'exceptionOrTitle:',
             exceptionOrTitle,
             'message: ',
             message
          );
         };
       }
     })

     instance.register('service:bugsnag', bugsnagService);
  }
};
