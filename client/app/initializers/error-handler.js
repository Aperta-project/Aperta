import logError from 'tahi/services/log-error';

export default {
  name: 'errorHandler',
  initialize(registry, application) {
    application.register('logError:main', logError, {
      instantiate: false
    });

    application.inject('route', 'logError', 'logError:main');
  }
};
