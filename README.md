# AWS-Discord-Bot

Discord bot used for managing AWS instances including status and toggling on or off via chat commands in a Discord text channel. This is based on https://github.com/JamesMatchett/AWS-Discord-Bot.

## Setup
* Download [Node](https://nodejs.org/en/) and [aws-cli](https://aws.amazon.com/cli/).
* Run `aws configure` from the CLI on the machine you wish to host the bot from.
* Create a Discord application here https://discordapp.com/developers/applications/ and create a bot user under it.
* Add the bot account to your discord server (https://discordjs.guide/preparations/adding-your-bot-to-servers.html#creating-and-using-your-own-invite-link).
* Create a dedicated role on your discord server as well as a dedicated text channel for the bot.
* Gather the required credentials and IDs needed from AWS and Discord mentioned below.

Create a `.env` file with the following keys (_make sure to replace the values with your AWS and Discord ones_): 
```yaml
BOT_TOKEN=Your_Discord_bot_Token_here
ROLEID=Discord_Role_ID_for_the_role_that_can_use_the_bot
CHANNELID=Discord_Channel_ID_of_the_text_channel_where_the_bot_will_be_controlled_from
ACCESSKEY=AWS_Access_Key
SECRETKEY=AWS_Secret_Key
INSTANCE=EC2_instance_ID
MESSAGELOGGING=F #Or T for specific error messages logged tp the Discord channel which may contain sensitive info like keys and instance IDs
```

## Usage
Run the following in the target CLI:
```
npm start
```

### Discord commands
Commands: 
``` 
/aws start (Starts the specified instance)
/aws stop (Stops the specified instance)
/aws status (Returns status information about the instance, i.e. if it is running, it's IP, it's last startTime)
/aws info (General information about the instance)
```
You, and anyone else you give the role and channel access to, should be able to toggle the selected AWS instance on or off when needed as well as view instance information on demand.
