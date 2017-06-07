import Ember from 'ember';

// This is necessary because the `route-action` helper was written
// with controllers in mind. To test in components, we have to stub
// out the helper mechanics.
//
// Read more here:
// https://github.com/DockYard/ember-route-action-helper#overriding-route-action-for-integration-tests

export default function(container, actions){
  container.registry
    .registrations['helper:route-action'] =
    Ember.Helper.helper((arg) => {
      return actions[arg[0]];
    });
}
