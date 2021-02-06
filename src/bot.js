const { Options, Aws } = require('aws-cli-js');
const eris = require('eris');
require('dotenv').config();

const {
  ACCESSKEY,
  SECRETKEY,
  SESSIONTOKEN,
  INSTANCE,
  MESSAGELOGGING,
  BOT_TOKEN,
  ROLEID,
  CHANNELID
} = process.env;

const verboseLog = MESSAGELOGGING === 'T';

const options = new Options(
  ACCESSKEY,
  SECRETKEY,
  SESSIONTOKEN,
  null //currentWorkingDirectory
);

const aws = new Aws(options);

const PREFIX = '/aws';
const Command = {
  START: 'start',
  STOP: 'stop',
  HELP: 'help',
  STATUS: 'status',
  INFO: 'info',
  PING: 'ping'
};

// Create a Client instance with our bot token.
const bot = new eris.Client(BOT_TOKEN);

// When the bot is connected and ready, log to console.
bot.on('ready', () => {
  console.log('Connected and ready.');
});

const startStop = (msg, cmd = Command.START) => {
  const word = cmd === Command.START ? 'Starting' : 'Stopping';
  console.warn(`${word} the server`);
  try {
    aws
      .command(`ec2 ${cmd} -instances --instance-ids ${INSTANCE}`)
      .then((data) => {
        console.info('data = ', data);
        return msg.channel.createMessage(`<@${msg.author.id}> ${word} the server.`);
      })
      .catch((err) => {
        msg.channel.createMessage(
          `<@${msg.author.id}> Error ${word.toLowerCase()} the server${verboseLog && ': ' + err}`
        );
      });
  } catch (err) {
    msg.channel.createMessage(`<@${msg.author.id}> Error ${word.toLowerCase()} the server.`);
    return msg.channel.createMessage(err);
  }
};

const replyToStatus = (reply, authorId) => {
  return `<@${authorId}> *Status*:
  **Name**: ${reply.Tags.find((tag) => tag.Key === 'Name').Value}
  **State**: ${reply.State.Name}
  **IP Address**: ${reply.PublicIpAddress}
  **Last Startup**: ${reply.LaunchTime}`;
};

const replyToInfo = (reply, authorId) => {
  const tags = reply.Tags.reduce((acc, val) => `${acc}${val.Key}=${val.Value}\n\t`, '');
  return `<@${authorId}> *Info*:
**AMI**: ${reply.ImageId}
**Instance Type**: ${reply.InstanceType}
**Availability Zone**: ${reply.Placement.AvailabilityZone}
**Public IP Address**: ${reply.PublicIpAddress}
**Tags**:
\t${tags}
**CPU**: x${reply.CpuOptions.CoreCount}
**Monitoring**: ${reply.Monitoring.State}`;
};

const infoStatus = async (msg, cmd = Command.STATUS) => {
  console.info(`Getting server ${cmd}`);
  try {
    const data = await aws.command(`ec2 describe-instances --instance-id ${INSTANCE}`);
    const reply = data.object.Reservations[0].Instances[0];

    let response =
      cmd === Command.INFO
        ? replyToInfo(reply, msg.author.id)
        : replyToStatus(reply, msg.author.id);

    return msg.channel.createMessage(response);
  } catch (err) {
    console.warn(err);
    msg.channel.createMessage(
      `<@${msg.author.id}> Error getting ${cmd}${verboseLog && ': ' + err}`
    );
    return msg.channel.createMessage(err);
  }
};

const cmdHandler = {
  start(msg) {
    startStop(msg, true);
  },
  stop(msg) {
    startStop(msg, false);
  },
  help(msg) {
    return msg.channel.createMessage(`Help Docs:
\`${PREFIX} start\`: Starts the VM.
\`${PREFIX} stop\`: Stops the VM.
\`${PREFIX} status\`: Returns the VM' status.
\`${PREFIX} info\`: Returns the VM's information.
\`${PREFIX} ping\`: Gets the bot's roundtrip latency.`);
  },
  status(msg) {
    infoStatus(msg, Command.STATUS);
  },
  info(msg) {
    infoStatus(msg, Command.INFO);
  },
  async ping(msg) {
    const start = Date.now();
    const pong = await msg.channel.createMessage('Pong...');
    pong.edit(`Roundtrip latency: ${Date.now() - start}ms`);
  }
};

// Message handler
bot.on('messageCreate', async (msg) => {
  const content = msg.content;
  const botWasMentioned = msg.mentions.find((mentionedUser) => mentionedUser.id === bot.user.id);

  const wrongChannel = !(msg.channel.id === CHANNELID);
  const messagedByABot = msg.author.bot;
  const notCorrectlyPrefixed = !content.startsWith(PREFIX);
  if (wrongChannel || messagedByABot || notCorrectlyPrefixed) {
    return;
  }

  if (!msg.member.roles.includes(ROLEID)) {
    await msg.channel.createMessage(`<@${msg.author.id}> You do not have the required roles`);
    return;
  }

  if (botWasMentioned) {
    await msg.channel.createMessage('Brewing the coffee and ready to go!');
  }

  //Ignore DMs, guild messages only
  if (!msg.channel.guild) {
    await msg.channel.createMessage('Fuck off with your DMs');
    return;
  }

  const commandName = content.split(PREFIX)[1].trim();

  if (!(commandName in cmdHandler)) {
    await msg.channel.createMessage(
      `Unknown command, try \`${PREFIX} help\` for a list of commands`
    );
    return;
  }

  // eslint-disable-next-line security/detect-object-injection
  const commandHandler = cmdHandler[commandName];

  try {
    await commandHandler(msg, commandName);
  } catch (err) {
    console.warn('Error handling command');
    console.warn(err);
  }
});

bot.on('error', (err) => {
  console.warn(err);
});

bot.connect();

const gracefulClosure = () => {
  console.log('Shutting down the bot');
  // bot.editStatus('invisible', { name: 'DevOps' });
  // bot.disconnect();
  process.exit();
};

process.on('SIGTERM', gracefulClosure);
process.on('SIGINT', gracefulClosure);
