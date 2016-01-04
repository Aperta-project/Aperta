import Ember from 'ember';
import { Ability } from 'ember-can';

export default Ability.extend({

  init: function() {
    this._super();
    this._loadData();
  },

  _loadData: function(){
    this.get('data').forEach( (data) => {
      let key = `${data.object.type}-${data.object.id}`;
      this.set(key, data.permissions);
    });
  },

  can: Ember.computed('model', function(){
    // this is the model/resource we're checking permissions on
    let model = this.get('model');
    let modelType = model.get('constructor.modelName');
    let modelId = model.get('id');

    // When we don't have a modelId let us assume this is aclient-side created
    // object and that the user has full permissions to whatever they
    // create.
    if(!modelId){
      return true;
    } else {
      let lookupKey = `${Ember.String.classify(modelType)}-${modelId}`;
      return this.__hasAbilityToPerformAction(this.get('action'), this.get(lookupKey), model);
    }
  }),

  __hasAbilityToPerformAction: function(action, permissions, model){
    if(!permissions){
      return false;
    }

    let permissibleAction = permissions[action];
    if(!permissibleAction){
      return false;
    }

    // Hard-code state for now, but this should likely come back with the permission
    // data from the server, as the field may be named something else.
    let permissibleStates = permissibleAction.states || [];
    let actualState = model.get('state') || '*';
    return permissibleStates.contains(actualState);
  },

  // Fake data from the server
  data: [
    {
      'object': {
        'id': 2,
        'type': 'Journal'
      },
      'permissions': {
        'read': {
          'states': [
            '*'
          ]
        },
        'write': {
          'states': [
            'in_progress'
          ]
        },
        'view': {
          'states': [
            '*'
          ]
        },
        'talk': {
          'states': [
            'in_progress',
            'in_review'
          ]
        }
      }
    },
    {
      'object': {
        'id': 99,
        'type': 'Journal'
      },
      'permissions': {
        'read': {
          'states': [
            '*'
          ]
        },
        'write': {
          'states': [
            'in_progress'
          ]
        },
        'view': {
          'states': [
            '*'
          ]
        },
        'talk': {
          'states': [
            'in_progress',
            'in_review'
          ]
        }
      }
    },
    {
      'object': {
        'id': 100,
        'type': 'Paper'
      },
      'permissions': {
        'read': {
          'states': [
            '*'
          ]
        },
        'write': {
          'states': [
            'in_progress'
          ]
        },
        'view': {
          'states': [
            '*'
          ]
        },
        'talk': {
          'states': [
            'in_progress',
            'in_review'
          ]
        }
      }
    }
  ]

});
