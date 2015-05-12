`import DS from 'ember-data'`

ApplicationAdapter = DS.ActiveModelAdapter.extend

  namespace: 'api'
  headers: (->
    'PUSHER_SOCKET_ID': @get('container').lookup('pusher:main').get('socketId')
  ).property().volatile()


`export default ApplicationAdapter`
