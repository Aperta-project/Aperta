import { ActiveModelSerializer } from 'active-model-adapter';

export default ActiveModelSerializer.extend(DS.EmbeddedRecordsMixin, {
  isNewSerializerAPI: true,

  attrs: {
    roles: {
      serialize: 'ids',
      deserialize: 'ids'
    }
  }
});
