window.deprecationWorkflow = window.deprecationWorkflow || {};
window.deprecationWorkflow.config = {
  workflow: [
    { handler: 'silence', matchId: 'ember-resolver.legacy-shims' },
    { handler: 'silence', matchId: 'ember-application.injected-container' },
    { handler: 'silence', matchId: 'ember-application.app-initializer-initialize-arguments' },
    { handler: 'silence', matchId: 'ember-application.app-instance-container' },
    { handler: 'silence', matchId: 'ember-application.app-instance-registry' },
    { handler: 'silence', matchId: 'ember-runtime.enumerable-contains' },
    { handler: 'silence', matchId: 'ember-views.did-init-attrs' }
  ]
};
