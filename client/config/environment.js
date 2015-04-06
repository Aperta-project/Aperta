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
      PUSHER_OPTS: {
        key: '765ec374ae0a69f4ce44',
        connection: {
          authEndpoint: "/event_stream/auth"
        },
        hostOptions: {
          PUSHER_HOST: "localhost",
          PUSHER_WS_PORT: "8080",
          PUSHER_PROTOCOL: 7
        }
      }
    },
    'ember-cli-visualeditor': {
      assetsRoot: '/assets/tahi'
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
    // ENV.APP.LOG_RESOLVER = true;
    ENV.APP.LOG_ACTIVE_GENERATION = true;
    ENV.APP.LOG_TRANSITIONS = true;
    ENV.APP.LOG_TRANSITIONS_INTERNAL = true;
    ENV.APP.LOG_VIEW_LOOKUPS = true;

    // include unminified assets for debugging
    ENV['ember-cli-visualeditor'].forceUnminified = true;

  }

  if (environment === 'test') {
    // Testem prefers this...
    ENV.baseURL = '/';
    ENV.locationType = 'none';

    // keep test console output quieter
    ENV.APP.LOG_ACTIVE_GENERATION = false;
    ENV.APP.LOG_VIEW_LOOKUPS = false;

    ENV.APP.rootElement = '#ember-testing';

    // here we include the assets into the vendor bundle
    // as we had troubles here with loading them lazily
    ENV['ember-cli-visualeditor'].includeAssets = true;
    // And, we need to use a different root for served assets
    ENV['ember-cli-visualeditor'].assetsRoot = '/assets';

    // Override automatic loading of VE assets
    ENV['ember-cli-visualeditor'].useMock = true;
  }

  if (environment === 'production') {
    // manage assets manually (as workaround for problems
    // with ember-cli assets pipeline / uglify)
    ENV['ember-cli-visualeditor'].assetsRoot = '/';
    ENV['ember-cli-visualeditor'].manual = true;
  }

  return ENV;
};
