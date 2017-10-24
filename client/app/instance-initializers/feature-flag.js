export function initialize(app) {
  const flagService = app.lookup('service:feature-flag');
  flagService.setup();
}

export default {
  name: 'feature-flag',
  after: 'pusher-setup',
  initialize: initialize
};
