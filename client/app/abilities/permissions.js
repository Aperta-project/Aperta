import Ember from 'ember';
import { Ability } from 'ember-can';

/*
* The permissions ability is used to determine access on a model with a
* given action and set of permission data.
*
* It is not intended to be used directly, but thru the CanService and
* related helpers from ember-can.
*/
export default Ability.extend({
  // property for the permission data to be stored
  data: null,

  can: Ember.computed('data', 'model', 'action', function(){
    // this is the model/resource we're checking permissions on
    let model = this.get('model');
    if(!model) return;

    let modelType = model.get('constructor.modelName');
    let modelId = model.get('id');

    // When there is no model id assume this is a client-side created object
    // that the user has all permissions on.
    if(!modelId){
      return true;
    } else {
      let lookupKey = `${Ember.String.classify(modelType)}-${modelId}`;
      return this.__hasAbilityToPerformAction(
        this.get('action'),
        this.get(lookupKey),
        model
      );
    }
  }),

  // Expand the permission data into a simple set of lookup values
  _loadData: Ember.observer('data', function(){
    let data = this.get('data');
    if(data){
      data.forEach( (data) => {
        let key = `${data.object.type}-${data.object.id}`;
        this.set(key, data.permissions);
      });
    }
  }),

  __hasAbilityToPerformAction: function(action, permissions, model){
    let defaultStateProperty = 'state';
    let anyPermissionState = '*';

    if(!permissions){
      return false;
    }

    let permissibleAction = permissions[action];
    if(!permissibleAction){
      return false;
    }

    // Hard-code state for now, but this should likely come back with the
    // permission data from the server, as the field may be named something
    // else.
    let permissibleStates = permissibleAction.states || [];

    // the model can provide a property that tells us which property should
    // be used to match against the permission state. By default it's
    let statePropertyForPermission = model.get('statePropertyForPermissions');
    let actualState;
    if(statePropertyForPermission){
      actualState = model.get(statePropertyForPermission);
    } else {
      actualState = model.get(defaultStateProperty) || anyPermissionState;
    }

    return permissibleStates.contains(actualState);
  }
});
