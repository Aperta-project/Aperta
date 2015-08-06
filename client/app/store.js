import DS from 'ember-data';

export default DS.Store.extend({
  push(type, data, _partial) {
    let oldRecord;
    let oldType = type;
    let dataType = data.type;
    let modelType = oldType;

    if (dataType && (this.modelFor(oldType) !== this.modelFor(dataType))) {
      modelType = dataType;
      if (oldRecord = this.getById(oldType, data.id)) {
        this.dematerializeRecord(oldRecord);
      }
    }
    return this._super(this.modelFor(modelType), data, _partial);
  },

  findTask(id) {
    let matchingTask = this.allTaskClasses().find(function(tm) {
      return tm.idToRecord[id];
    });
    if (matchingTask) {
      return matchingTask.idToRecord[id];
    }
  },

  allTaskClasses() {
    return Object.keys(this.typeMaps).reduce((function(_this) {
      return function(memo, key) {
        let typeMap = _this.typeMaps[key];
        if (typeMap.type.toString().match(/:.*task:/)) {
          memo.addObject(typeMap);
        }
        return memo;
      };
    })(this), []);
  }
});
