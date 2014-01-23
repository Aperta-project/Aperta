window.Tahi ||= {}

subUid = -1
topics = {}

Tahi.pubsub =
  publish: (topic, args) ->
    subscribers = topics[topic]
    return false unless subscribers
    setTimeout (->
      for subscriber in subscribers
        subscriber.func topic, args
    ), 0
    true

  subscribe: (topic, func) ->
    topics[topic] ||= []

    token = ++subUid
    topics[topic].push
      token: token
      func: func

    token

  unsubscribe: (token) ->
    for topic of topics
      if topics[topic]
        topics[topic] = topics[topic].filter (i) -> i.token != token
