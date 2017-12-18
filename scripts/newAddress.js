const bitcoin = require('bitcoinjs-lib')
// const R = require('ramda')

module.exports = robot => {
  robot.respond(/gen WIF/i, res => res.send(
    bitcoin.ECPair.makeRandom().toWIF()
    )
  )
}
