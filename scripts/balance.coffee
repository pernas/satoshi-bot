balanceResponse = (balance, address) -> {
  text: 'Address Information',
  attachments: [
    {
      title: "Balance: #{balance / 100000000} BTC",
      image_url: "https://blockchain.info/qr?data=#{address}&size=200",
      color: "#3AA3E3"
    }
  ]
}

module.exports = (robot) ->
  robot.respond /balance (.*)/i, (msg) ->
    address = escape(msg.match[1])
    msg.http("https://blockchain.info/address/#{address}?format=json")
      .get() (err, res, body) ->
        try
          json = JSON.parse(body)
          msg.send(balanceResponse(json.final_balance, address))
        catch error
          msg.send "Address not found"
