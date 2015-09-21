
require('../styles/index.sass')
Application = require('./application')

React.render(
  Application(
    history: true
  ), document.getElementById('react__entry')
)

