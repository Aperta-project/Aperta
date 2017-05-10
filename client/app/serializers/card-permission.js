import { ActiveModelSerializer } from 'active-model-adapter';

export default ActiveModelSerializer.extend(DS.EmbeddedRecordsMixin, {
  attrs: {
    roles: {
      serialize: 'ids',
      deserialize: 'ids'
    }
  }
});
