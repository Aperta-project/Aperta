import logError from 'tahi/pods/log-error/service';

export default {
  name: 'errorHandler',
  initialize(registry, application) {
    application.register('logError:main', logError, {
      instantiate: false
    });

    application.inject('route', 'logError', 'logError:main');
  }
};
