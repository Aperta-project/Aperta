ETahi.FlowManagerRoute = Ember.Route.extend
  model: ->
    store = @store

    $.getJSON('/flow_managers').then (data) ->
      flows = data.flows.map (flow)-> 
        flow.paperProfiles.forEach (pp) ->
          pp.tasks.forEach (t) ->
            store.push('task', t)
        ETahi.Flow.create(flow)
