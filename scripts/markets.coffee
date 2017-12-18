numeral = require('numeral')
R = require('ramda')

green = "#7CFC00"
red = "#DC143C"
blue = "#3AA3E3"


int7dayPer = R.compose(parseFloat, R.prop('percent_change_7d'))
int1dayPer = R.compose(parseFloat, R.prop('percent_change_24h'))
notNil = (nameProp) -> R.compose(R.not, R.isNil, R.prop(nameProp))

printCoin7Change = (json) -> ({
  title: "#{json.name}: #{numeral(json.percent_change_7d / 100).format('0.00 %')}",
  color: (if json.percent_change_7d > 0 then green else red)
})

printCoin1Change = (json) -> ({
  title: "#{json.name}: #{numeral(json.percent_change_24h/ 100).format('0.00 %')}",
  color: (if json.percent_change_24h > 0 then green else red)
})

globalMarketResponse = (json) -> {
  text: 'Market cap',
  attachments: [
    {
      title: "Total: #{numeral(json.total_market_cap_usd).format('($ 0.00 a)')}",
      color: blue
    },
    {
      title: "Bitcoin: #{numeral(json.bitcoin_percentage_of_market_cap / 100).format('0.00 %')}",
      color: blue
    },
    {
      title: "24h vol: #{numeral(json.total_24h_volume_usd).format('($ 0.00 a)')}",
      color: blue
    }
  ]
}

infoResponse = (json) -> {
  text: json.name,
  attachments: [
    {
      title: "Price: #{numeral(json.price_usd).format('$0,0.00')}",
      color: blue
    },
    {
      title: "Daily change: #{numeral(json.percent_change_24h / 100).format('0.00 %')}",
      color: (if json.percent_change_24h > 0 then green else red)
    },
    {
      title: "Weekly change: #{numeral(json.percent_change_7d / 100).format('0.00 %')}",
      color: (if json.percent_change_7d > 0 then green else red)
    },
    {
      title: "24h vol: #{numeral(R.prop('24h_volume_usd',json)).format('($ 0.00 a)')}",
      color: blue
    },
    {
      title: "Market cap: #{numeral(json.market_cap_usd).format('($ 0.00 a)')}",
      color: blue
    },
    {
      title: "Total supply: #{numeral(json.available_supply).format('(0.00 a)')}",
      color: blue
    }
  ]
}

module.exports = (robot) ->
  robot.respond /market cap/i, (msg) ->
    msg.http("https://api.coinmarketcap.com/v1/global/")
      .get() (err, res, body) ->
        try
          json = JSON.parse(body)
          msg.send(globalMarketResponse(json))
        catch error
          msg.send "Market not found"

  robot.respond /info (.*)/i, (msg) ->
    cryptocurrency = escape(msg.match[1])
    msg.http("https://api.coinmarketcap.com/v1/ticker/#{cryptocurrency}/")
      .get() (err, res, body) ->
        try
          json = R.head(JSON.parse(body))
          msg.send(infoResponse(json))
        catch error
          msg.send "Crypto not found"

  robot.respond /top 10 day/i, (msg) ->
    msg.http("https://api.coinmarketcap.com/v1/ticker/?limit=0/")
      .get() (err, res, body) ->
        try
          json = JSON.parse(body)
          top10 = R.take(10, R.sortWith([R.descend(int1dayPer)])(json))
          response = {
            text: 'Top daily change'
            attachments: R.map(printCoin1Change, top10)
          }
          msg.send(response)
        catch error
          msg.send "Not found"

  robot.respond /top 10 week/i, (msg) ->
    msg.http("https://api.coinmarketcap.com/v1/ticker/?limit=0/")
      .get() (err, res, body) ->
        try
          json = JSON.parse(body)
          top10 = R.take(10, R.sortWith([R.descend(int7dayPer)])(json))
          response = {
            text: 'Top weekly change'
            attachments: R.map(printCoin7Change, top10)
          }
          msg.send(response)
        catch error
          msg.send "Not found"

  robot.respond /bottom 10 day/i, (msg) ->
    msg.http("https://api.coinmarketcap.com/v1/ticker/?limit=0/")
      .get() (err, res, body) ->
        try
          json = JSON.parse(body)
          filtered = R.filter(notNil('percent_change_24h'), json)
          bottom10 = R.take(10, R.sortWith([R.ascend(int1dayPer)])(filtered))
          response = {
            text: 'Worst daily change'
            attachments: R.map(printCoin1Change, bottom10)
          }
          msg.send(response)
        catch error
          msg.send JSON.stringify(error)

  robot.respond /bottom 10 week/i, (msg) ->
    msg.http("https://api.coinmarketcap.com/v1/ticker/?limit=0/")
      .get() (err, res, body) ->
        try
          json = JSON.parse(body)
          filtered = R.filter(notNil('percent_change_7d'), json)
          bottom10 = R.take(10, R.sortWith([R.ascend(int7dayPer)])(filtered))
          response = {
            text: 'Worst weekly change'
            attachments: R.map(printCoin7Change, bottom10)
          }
          msg.send(response)
        catch error
          console.log(error)
          msg.send JSON.stringify(error)
