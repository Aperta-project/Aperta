describe "Tahi overlay components", ->
  describe "OverlayHeader", ->
    describe "#render", ->
      it "includes the paper title which is a link to the paper", ->
        component = Tahi.overlays.components.OverlayHeader
          paperTitle: 'A title'
          paperPath: '/path/to/paper'

        link = component.render().props.children[0].props.children
        expect(link.props.href).toEqual '/path/to/paper'
        expect(link.props.children).toEqual 'A title'

      # it "includes the paper title which is a link to the paper", (done) ->
      #   component = Tahi.overlays.components.OverlayHeader
      #     paperTitle: 'A title'
      #     paperPath: '/path/to/paper'

      #   React.renderComponentToString component, (markup) ->
      #     link = $('h2 a', markup)
      #     expect(link.attr 'href').toEqual '/path/to/paper'
      #     expect(link.text()).toEqual 'A title'
      #     done()

      it "passes an on click callback to the close button", ->
        callback = ->
        component = Tahi.overlays.components.OverlayHeader
          closeCallback: callback

        button  = component.render().props.children[1]
        expect(button.props.onClick).toEqual callback

  describe "OverlayFooter", ->
    describe "#render", ->
      it "passes an on click callback to the close button", ->
        callback = ->
        component = Tahi.overlays.components.OverlayFooter
          closeCallback: callback

        button  = component.render().props.children[1]
        expect(button.props.onClick).toEqual callback

  describe "RailsFormHiddenDiv", ->
    describe "#render", ->
      it "contains a hidden field containing the specified method", ->
        component = Tahi.overlays.components.RailsFormHiddenDiv method: 'foo'
        methodField  = component.render().props.children[1]
        expect(methodField.props.value).toEqual 'foo'

      # it "contains a hidden field containing the specified method", (done) ->
      #   component = Tahi.overlays.components.RailsFormHiddenDiv method: 'foo'
      #   React.renderComponentToString component, (markup) ->
      #     field = $('input[name="_method"]', markup)
      #     expect(field.val()).toEqual 'foo'
      #     done()
