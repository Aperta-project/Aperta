import DS from 'ember-data';
import Ember from 'ember';

export default DS.Store.extend({
  push(data) {
    if (!data){
      return; // if we've managed to get falsey data don't try to push it in
    }
    return this._super(data);
  },

  getPolymorphic(modelName, id) {
    var task = null;
    if (modelName === 'task' && (task = this.findTask(id))) {
      return task;
    } else {
      return this.peekRecord(modelName, id);
    }
  },

  findTask(id) {
    let matchingTask = this.allTaskClasses().find(function(tm) {
      return tm.idToRecord[id];
    });
    if (matchingTask) {
      return this.peekRecord(matchingTask.type.modelName, id);
    }
  },

  findOrPush(type, modelData) {
    // remember that filteredUserData only has a subset of the
    // fields we need to push a proper user in to the store,
    // so we look up the full user in the availableUsers array
    //
    Ember.assert(modelData.id, 'Model Data must have an id');

    let stringId = modelData.id.toString();
    var foundModel = this.peekRecord(type, stringId);
    if (foundModel) {
      return foundModel;
    } else {
      let typeKey = type.underscore();
      let payload = {};
      payload[typeKey] = modelData;

      this.pushPayload(type, payload);
      let newModel = this.peekRecord(type, stringId);
      Ember.assert(!!newModel, 'store.findOrPush must return a model of some kind');
      return newModel;
    }
  },

  allTaskClasses() {
    return Object.keys(this.typeMaps).reduce((function(_this) {
      return function(memo, key) {
        let typeMap = _this.typeMaps[key];
        if (typeMap.type.toString().match(/:.+task:/)) {
          memo.addObject(typeMap);
        }
        return memo;
      };
    })(this), []);
  },

  // These are helper methods to get an answer from the already fetched, stored,
  // answers based on the ident and owner. Useful because many answer
  // relationships are async, this does not return a promise.
  peekAnswer(ident, owner) {
    let content = this.peekCardContent(ident);
    return this.peekAll('answer').find((a) => {
      return a.get('cardContent') === content && a.get('owner') === owner;
    });
  },
  peekCard(name) {
    return this.peekAll('card').findBy('name', name);
  },
  peekCardContent(ident) {
    return this.peekAll('card-content').findBy('ident', ident);
  }
});
