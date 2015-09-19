require('./styles/index.sass')

{ div } = React.DOM

module.exports = Component.create
  displayName: 'Component:DemoComponent'

  mixins: require('./mixins/index.coffee')

  render: ->
    div className: 'demo-component',
      'Demo Component'
      'I can do math!'
      @formulaOfSum([1, 2, 3, 4, 5])

