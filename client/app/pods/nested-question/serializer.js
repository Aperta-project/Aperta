import ApplicationSerializer from 'tahi/serializers/application';
import DS from 'ember-data';

export default ApplicationSerializer.extend(DS.EmbeddedRecordsMixin, {
  attrs: {
    children: {embedded: 'always'}
  },

  normalizeRelationships: function(typeClass, hash){
    var payloadKey;

    if (this.keyForRelationship) {
      typeClass.eachRelationship(function(key, relationship) {
        payloadKey = this.keyForRelationship(key, relationship.kind, 'deserialize');
        if(key === payloadKey){
          hash[key] = this.normalizeType(hash[key]);
          return;
        }
        if (!hash.hasOwnProperty(payloadKey)) {
          hash[key] = this.normalizeType(hash[payloadKey]);
          return;
        }

        hash[key] = this.normalizeType(hash[payloadKey]);
        delete hash[payloadKey];
      }, this);
    }
  }

});
