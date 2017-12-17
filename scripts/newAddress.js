const bitcoin = require('bitcoinjs-lib')
// const R = require('ramda')

module.exports = robot => {
  robot.hear(/WIF/i, res => res.send(
    bitcoin.ECPair.makeRandom().toWIF()
    )
  )
}
