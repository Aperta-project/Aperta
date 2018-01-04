import Ember from 'ember';
import deNamespaceTaskType from 'tahi/lib/de-namespace-task-type';
import { ActiveModelSerializer } from 'active-model-adapter';

export default ActiveModelSerializer.extend({
  isNewSerializerAPI: true,

  // We add qualifiedType and modify type when the payload comes in.
  // Revert this on the way out.

  serialize(record, options) {
    return this._unsetQualifiedType(this._super(record, options));
  },

  pushPayload(store, payload) {
    let normalized = this._normalizePayloadData(payload);

    return this._super(store, normalized);

  },

  normalizeSingleResponse(store, primaryModelClass, originalPayload, recordId, requestType) {
    let {newModelName, payload} = this._newNormalize(
      primaryModelClass.modelName,
      this._mungePayloadTypes(originalPayload),
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
      this._mungePayloadTypes(originalPayload),
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

  // The Task payload has a key of `type`. This is the full
  // Ruby class name. Example: "ApertaThings::ImportantTask"
  // The Ember side is only interested in the last half.
  // Store the original full name in `qualified_type`
  // We snake case because our superclass expects it
  _setQualifiedType(taskObj) {
    const qualifiedType  = taskObj.type;

    if (qualifiedType) {
      taskObj.qualified_type = qualifiedType;
      taskObj.type = deNamespaceTaskType(taskObj.type);
    }

    return taskObj;
  },

  _unsetQualifiedType(taskObj) {
    if (taskObj.qualified_type) {
      taskObj.type = taskObj.qualified_type;
      delete taskObj.qualified_type;
    }
    return taskObj;
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

  _mungePayloadTypes(payload) {
    Object.values(payload).forEach((val) => {
      this._callOnceOrMap(val, this._setQualifiedType);
    });
    return payload;
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
            if(!payload[newBucketName]) { payload[newBucketName] = []; }

            if (newBucketName !== oldBucketName) {
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
          if(!payload[newBucketName]) { payload[newBucketName] = record; }

          if (newBucketName !== oldBucketName) {
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

    let singularPrimaryKey = modelName.underscore(),
      primaryKey = singularPrimaryKey.pluralize();

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
  },

  _normalizePayloadData(rawPayload){
    if(!rawPayload){
      return;
    }

    var newPayload = {};
    for(var key of Object.keys(rawPayload)) {
      let { payload } = this._newNormalize(key, rawPayload[key]);

      // if we get { tasks: [{...}], authors: [{...}] } back from _newNormalize
      // make sure we add all key/value pairs to newPayload
      for(var newKey of Object.keys(payload)){
        newPayload[newKey] = payload[newKey];
      }
    }

    return newPayload;
  }
});
