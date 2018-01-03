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
    if (modelName === 'task' && (task = this.peekTask(id))) {
      return task;
    } else {
      return this.peekRecord(modelName, id);
    }
  },

  peekTask(id) {
    return this.allTaskClasses().map((name) => {
      return this.peekRecord(name, id);
    }).compact().get('firstObject');
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
    var allModelClasses = _.map(this.typeMaps, function(typeMap){
      return _.pluck(typeMap.records, 'modelName');
    }).flatten().uniq();

    return allModelClasses.filter((k) => {
      return k.match(/-task/);
    });
  },
});
