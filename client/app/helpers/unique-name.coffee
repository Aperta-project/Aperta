`import Ember from 'ember'`

UniqueName = Ember.Handlebars.makeBoundHelper (count, classString) ->
  generateUUID = ->
    d = new Date().getTime()
    'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c)->
      r = (d + Math.random()*16)%16 | 0
      d = Math.floor(d/16)
      if c == 'x'
        r.toString(16)
      else
        (r&0x7|0x8).toString(16)
    )

  "#{name}-#{generateUUID()}"

`export default UniqueName`
