/* jshint node: true */

module.exports = function(environment) {
  var ENV = {
    modulePrefix: 'tahi',
    podModulePrefix: 'tahi/pods',
    environment: environment,
    baseURL: '/',
    locationType: 'auto',
    EmberENV: {
      FEATURES: {
        // Here you can enable experimental features on an ember canary build
        // e.g. 'with-controller': true
      }
    },
    APP: {
      // pusher configuration is set in initializers/pusher.js

      iHatExportFormats: [
        { type: 'docx', display: 'word' }
      ]
    },

    coffeeOptions: {
      blueprints: false
    },

    // Also set in /app/views/downloadable_paper/pdf.html.erb
    'mathjax': {
      url: '//cdn.mathjax.org/mathjax/latest/MathJax.js?config=MML_HTMLorMML'
    },

    contentSecurityPolicy: {
      'default-src': "'none'",
      'script-src': "'self' 'unsafe-eval'", // loading visualEditor via getScript
      'font-src': "'self'",
      'connect-src': "'self'",
      'img-src': "'self'",
      'style-src': "'self' 'unsafe-inline'", // Allow inline styles
      'media-src': "'self'"
    }
  };

  if (environment === 'development') {
    if(Error && Error.stackTraceLimit) {
      Error.stackTraceLimit = 50;
    }
    // ENV.APP.LOG_RESOLVER = true;
    // ENV.APP.LOG_ACTIVE_GENERATION = true;
    // ENV.APP.LOG_TRANSITIONS = true;
    // ENV.APP.LOG_TRANSITIONS_INTERNAL = true;
    // ENV.APP.LOG_VIEW_LOOKUPS = true;
  }

  if (environment === 'test') {
    // Testem prefers this...
    ENV.baseURL = '/';
    ENV.locationType = 'none';

    // keep test console output quieter
    ENV.APP.LOG_ACTIVE_GENERATION = false;
    ENV.APP.LOG_VIEW_LOOKUPS = false;

    ENV.APP.rootElement = '#ember-testing';
  }

  if (environment === 'production') {
  }

  return ENV;
};
