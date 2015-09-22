import DS from 'ember-data';

export default DS.Store.extend({
  push(type, data, _partial) {
    let oldRecord;
    let oldType = type;
    let dataType = data.type;
    let modelType = oldType;

    if (dataType && (this.modelFor(oldType) !== this.modelFor(dataType))) {
      modelType = dataType;
      if (oldRecord = this.peekRecord(oldType, data.id)) {
        this.dematerializeRecord(oldRecord);
      }
    }

    return this._super(modelType, data, _partial);
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
    return Object.keys(this.typeMaps).reduce((memo, key) => {
      let typeMap = this.typeMaps[key];

      if (typeMap.type.toString().match(/:.*task:/)) {
        memo.addObject(typeMap);
      }

      return memo;
    }, []);
  }
});
