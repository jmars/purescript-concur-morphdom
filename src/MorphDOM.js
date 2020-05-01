const morphdom = require('morphdom').default

exports._morphdom = (old, n, handlers) =>
  morphdom(old, n, {
    onBeforeElUpdated(from, to) {
      for (handler of handlers) {
        if (handler.n === to) {
          from.addEventListener(handler.t, handler.l)
        }
      }
    }
  })