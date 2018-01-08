import Ember from 'ember';
import deNamespaceTaskType from 'tahi/lib/de-namespace-task-type';
import { ActiveModelSerializer } from 'active-model-adapter';

export default ActiveModelSerializer.extend({
  isNewSerializerAPI: true,

  pushPayload(store, rawPayload) {
    var newPayload = {};
    for(var key of Object.keys(rawPayload)) {
      let { payload } = this._newNormalize(key, rawPayload[key]);
      Object.assign(newPayload, payload);
    }
    return this._super(store, newPayload);
  },

  normalizeSingleResponse(store, primaryModelClass, originalPayload, recordId, requestType) {
    let {newModelName, payload} = this._newNormalize(
      primaryModelClass.modelName,
      originalPayload,
      false
    );

    let newModelClass = store.modelFor(newModelName);
    return this._super.apply(
      this, [store, newModelClass, payload, recordId, requestType]
    );
  },

  normalizeArrayResponse(store, primaryModelClass, originalPayload, recordId, requestType) {
    let {newModelName, payload, isPolymorphic} = this._newNormalize(
      primaryModelClass.modelName,
      originalPayload,
      false
    );

    let newModelClass = store.modelFor(newModelName);
    let normalizedPayload = this._super.apply(
      this, [store, newModelClass, payload, recordId, requestType]
    );

    if (isPolymorphic) {
      if (!normalizedPayload.data) { normalizedPayload.data = []; }
      normalizedPayload.data.push(...normalizedPayload.included);
      delete normalizedPayload.included;
    }

    if (!normalizedPayload.data) { normalizedPayload.data = []; }
    return normalizedPayload;
  },

  /**
   * Call the function f once on a thing if it is not an array, or map with f if
   * thing is an array.
   * @param thing - Either an an array, or something else
   * @param f - function to call on thing
   */
  _callOnceOrMap(thing, f) {
    if (Ember.isArray(thing)) {
      return thing.map(f);
    } else {
      return f(thing);
    }
  },

  // returns new payload
  _pluralizePrimaryKeyData(singularKey, pluralKey, payload, assumeObject) {
    let newPayload = _.clone(payload);

    if((payload[singularKey] && payload[pluralKey])) {
      //if both keys are present, the singular key is the primary
      //record and the plural key should be sideloaded records

      newPayload[pluralKey] = payload[pluralKey].unshift(payload[singularKey]);
      delete payload[singularKey];
    } else {
      let singularPrimaryRecord = payload[singularKey];
      let pluralKeyRecord = payload[pluralKey];
      if (singularPrimaryRecord) {
        newPayload[pluralKey] = [singularPrimaryRecord];
        delete newPayload[singularKey];
      } else if(pluralKeyRecord) {
        //no-op
      } else if(assumeObject){
        newPayload = {};
        newPayload[pluralKey] = Ember.makeArray(payload);
      }
    }
    return newPayload;
  },

  _getPolymorphicModelName(modelName, records) {
    records = Ember.makeArray(records);

    if (records && records[0] && records[0].type) {
      return records[0].type.dasherize();
    } else {
      return modelName;
    }
  },

  _distributeRecordsByType(payload) {
    Object.keys(payload).forEach((oldBucketName) => {
      if (Ember.isArray(payload[oldBucketName])) {
        payload[oldBucketName].slice().forEach((record) => {
          const type = record.type;
          if (type) {
            let newBucketName = type.underscore().pluralize();
            if (newBucketName !== oldBucketName) {
              if(!payload[newBucketName]) { payload[newBucketName] = []; }
              payload[newBucketName].addObject(record);
              payload[oldBucketName].removeObject(record);
              if (Ember.isEmpty(payload[oldBucketName])) {
                delete payload[oldBucketName];
              }
            }
          }
        });
      } else {
        let record = payload[oldBucketName];
        const type = record.type;
        if (type) {
          let newBucketName = type.underscore();
          if (newBucketName !== oldBucketName) {
            payload[newBucketName] = record;
            delete payload[oldBucketName];
          }
        }
      }
    });
  },

  _hasMultipleTypes(records) {
    if (!Ember.isArray(records)) { return false; }

    return records.mapBy('type').uniq().length > 1;
  },

  _newNormalize(modelName, sourcePayload, assumeObject = true) {
    let payload = _.clone(sourcePayload);

    let singularPrimaryKey = modelName.underscore();
    let primaryKey = singularPrimaryKey.pluralize();

    // author_task: {} ===> author_tasks: [{}]
    let newPayload = this._pluralizePrimaryKeyData(singularPrimaryKey, primaryKey, payload, assumeObject);

    let primaryContent = payload[primaryKey];
    // if the primary key's content has a type, and that type is different than the modelName,
    // then THAT type should be the model name when we call super.
    let newModelName = this._getPolymorphicModelName(modelName, newPayload[primaryKey]);

    // the payload is 'polymorphic' if the returned type is different than the one we asked for,
    // or if the payload has multiple different types.
    let isPolymorphic = (newModelName !== modelName) || this._hasMultipleTypes(primaryContent);

    // loop through each key in the payload and move models into buckets based on their dasherized and pluralized 'type'
    // attributes if they have them
    this._distributeRecordsByType(newPayload);

    return {newModelName, payload: newPayload, isPolymorphic};
  }
});
