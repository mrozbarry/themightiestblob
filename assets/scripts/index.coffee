
require('../styles/index.sass')
Application = require('./application')

container = document.createElement('div')
document.body.appendChild(container)

ReactDOM.render(
  Application(), container
)

