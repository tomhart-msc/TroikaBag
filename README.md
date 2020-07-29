# TroikaBag

TroikaBag is a Discord bot for playing [Troika!](https://www.troikarpg.com/) It supports simulating Troika's initiative system digitally, in order to support remote play.

Troika handles initiative by putting two tokens into a bag per PC, and a variable number of tokens per enemy, governed by its Initiative stat. There is also an end-of-round token. When your token is drawn, you can act. After the end-of-round token is drawn, tokens for all living PCs and enemies are restored to the bag. Hence, there is no guarantee that anyone gets to act in a given round.

## Using TroikaBag

TroikaBag responds to the `!fill` and `!next` commands. They are easiest to explain by example:

```
Tom> !fill gilroy:2 Ulu:2 Ekodat:3
TroikaBot> Bag has been filled!
Tom> !next
TroikaBot> Ekodat
Tom> !next
TroikaBot> Ulu
Tom> !next
TroikaBot> END OF ROUND
```

TroikaBag creates one bag per channel on your server.

TroikaBag also allows you to create named counters, which are useful in multiple games. Example:

```
Tom> !set refresh 10
TroikaBot> 10
Tom> !get refresh
TroikaBot> 10
Tom> !sub refresh 1
TroikaBot> 9
Tom> !add refresh 2
TroikaBot> 11
```

## Installation

There is no public release of TroikaBot but you can run it on your Discord server by creating an application and bot, and telling TroikaBot your bot token. Add it to `config/config.exs`

Run the bot using `iex -S mix`

Good instructions for creating a bot in Discord, including inviting it to your servers [are here](https://www.howtogeek.com/364225/how-to-make-your-own-discord-bot/).