# dasher-docker-rpi

A docker file for a dasher installation on a rpi to control a e.g. squeezebox server on a max2play.

I had a RaspberryPi3 (rpi) with a Max2Play Image (https://www.max2play.com/) with LMS (SqueezeBox Server) and Jivelite to run a small office web and spotify radio. It can be easily controlled by WebUI or several apps. But when I was about to left the office, I always noticed that I have forgot to turn off the radio. Powering the Computer back on seems not to be a very smart solution. A IoT Button next to the door should do the trick. I read something about hacking amazons dash button and the 5 € you will get back with first order.

I found maddox/dasher on GitHub, but it's a little bit outdated and will not run with the current node version. While trying to get it to work, I have messed everything up and the radio player client stopped working caused by the downgraded node version. I had Docker on my bucket list and it seems predestined for the job. I am totally newbie to this topic and I will be thankful for any advice.

## Required hardware

- RaspberryPi2/3/+ with a Rasbian derivate (e.g. Max2Play)
- Amazon Dash Button\*

\*) Buy one for a product you need at least one time, setup it up as intended and place your order. Remove the button in the Amazon App and set it up as described below.

## Required software

- docker
- dasher: https://github.com/maddox/dasher

## Setup

You'll want to set up your Dash buttons as well as Dasher.

### Dash button

Setting up your Dash button is as simple as following the instructions provided
by Amazon **EXCEPT FOR THE LAST STEP**. Just follow the instructions to set it
up in their mobile app. When you get to the step where it asks you to pick which
product you want to map it to, just quit the setup process.

The button will be set up and available on your network.

Here are few protips about Dash buttons that will help you plan how to use them.

- Dash buttons take ~5 seconds to trigger your action.
- Use DHCP Reservation on your Dash button to lower the latency from ~5s to ~1s.
- Dash buttons are discrete buttons. There is no on or off. They just do a
  single command.
- Dash buttons can not be used for another ~10 seconds after they've been pressed.

Dash buttons should be used to trigger specific things. I.E. a scene in
your home automation, as a way to turn everything off in your house, or
as a simple counter.

### Setup Docker on RPi

Connect to your RPi via ssh and run

```Bash
 curl -sSL https://get.docker.com | sh
```

See output, if you are not a root user, you can add your user to the docker group with
e.g.

```Bash
sudo usermod -aG docker pi
```

but you have to log out and back in to take effect.

Test if it works with

```bash
docker info
```

### Get the image and setup dasher-docker

If you have a RPi version 1

```bash
docker pull r11lein/dasher-docker-rpi:RPi1
```

If you have a RPi2 or RPi3 like me. Further examples will have this `:RPi3` tag on the image. You'll have to change it when you a Version 1 Pi.

```bash
docker pull r11lein/dasher-docker-rpi:RPi3
```

This will take some minutes, grab a coffee. ☕

Copy config files to host and start `find_button` script with

```bash
mkdir dasher-config
docker run --rm -it --net host --mount type=bind,src="$(pwd)"/dasher-config,dst=/root/docker-dasher/config --name dasher-docker-rpi r11lein/dasher-docker-rpi:RPi3 script/init
```

We looking for the MAC address of your Dash button. Press your button and look for it. Should be something with "Amazon..." or in my case "unknown". My network was quite noisy for arp messages. You can press your button twice or more times to verify but keep in mind, you have to wait 10 seconds between. Hit `CTRL + C` to stop the docker container.

<pre>
Copy Files to Host...
Watching for arp & udp requests on your local network, please try to press your dash now
Dash buttons should appear as manufactured by 'Amazon Technologies Inc.'
Possible dash hardware address detected: 00:1e:8c:a8:28:36 Manufacturer: ASUSTek COMPUTER INC. Protocol: arp
Possible dash hardware address detected: 00:15:5d:01:f1:03 Manufacturer: Microsoft Corporation Protocol: arp
Possible dash hardware address detected: 4c:9e:ff:80:7f:22 Manufacturer: ZyXEL Communications Corporation Protocol: arp
Possible dash hardware address detected: 00:1b:21:b0:1a:4c Manufacturer: Intel Corporate Protocol: arp
Possible dash hardware address detected: 00:1b:21:b0:1a:4c Manufacturer: Intel Corporate Protocol: arp
Possible dash hardware address detected: 00:1b:21:b0:1a:4c Manufacturer: Intel Corporate Protocol: arp
Possible dash hardware address detected: 00:1b:21:b0:1a:4c Manufacturer: Intel Corporate Protocol: arp
Possible dash hardware address detected: <b style="color:yellow">fc:65:de:75:d1:57</b> Manufacturer: <b style="color:yellow">unknown</b> Protocol: udp
Possible dash hardware address detected: 00:0c:29:fd:de:8f Manufacturer: VMware Protocol: udp
Possible dash hardware address detected: <b style="color:yellow">fc:65:de:75:d1:57</b> Manufacturer: <b style="color:yellow">unknown</b> Protocol: arp
Possible dash hardware address detected: <b style="color:yellow">fc:65:de:75:d1:57</b> Manufacturer: <b style="color:yellow">unknown</b> Protocol: arp
Possible dash hardware address detected: 00:1e:8c:a8:28:36 Manufacturer: ASUSTek COMPUTER INC. Protocol: arp
Possible dash hardware address detected: 00:15:5d:01:f1:03 Manufacturer: Microsoft Corporation Protocol: arp
Possible dash hardware address detected: 4c:9e:ff:80:7f:22 Manufacturer: ZyXEL Communications Corporation Protocol: arp
</pre>

Alternatively you can just look in your routers DHCP table.

Open `~/dasher-config/config.json` with a editor of your choice and edit the MAC to yours and the url to your needs. Further config and multiple buttons can found below or in the `~/dasher-config/config.examble.json`

e.g.

```Bash
nano dasher-config/config.json
```

```JSON
{"buttons":[
  {
    "name": "Finish Radio",
    "address": "fc:65:de:75:d1:57",
    "url": "http://max2play:9000/status.html?p0=pause",
    "method": "GET"
  }
]}
```

If you just need to run the scan/find script again.

```bash
docker run --rm -it --net host --mount type=bind,src="$(pwd)"/dasher-config,dst=/root/docker-dasher/config --name dasher-docker-rpi r11lein/dasher-docker-rpi:RPi3 script/find_button
```

### Testing

```Bash
docker run --rm -it --net host -v "$(pwd)"/dasher-config:/root/docker-dasher/config --name dasher-docker-rpi r11lein/dasher-docker-rpi:RPi3
```

```Log
> dasher@1.4.1 start /root/docker-dasher
> node app.js

[2018-06-15T13:53:50.133Z] Finish Radio added.
[2018-06-15T13:54:09.858Z] Finish Radio pressed. Count: 1
```

The last line should appear when you push your button and everything is setup correctly. `STRG + C` will stop the container again.

### Run Forever

docker run -d --restart unless-stopped --net host -v "$(pwd)"/dasher-config:/root/docker-dasher/config --name dasher-docker-rpi r11lein/dasher-docker-rpi:RPi3

After a reboot of your Pi a `docker ps` should look like this.

```
CONTAINER ID        IMAGE                            COMMAND                  CREATED             STATUS              PORTS               NAMES
f18c8a4f6f81        r11lein/dasher-docker-rpi:RPi3   "/bin/sh -c 'npm run…"   5 minutes ago       Up 2 seconds                            dasher-docker-rpi
```

#

#

#

docker run --rm -it --net host --mount type=bind,src="$(pwd)"/dasher-config,dst=/root/docker-dasher/config --name dasher-docker-rpi r11lein/dasher-docker-rpi script/init

docker run --rm -it --net host -v "$(pwd)"/dasher-config:/root/docker-dasher/config --name dasher-docker-rpi r11lein/dasher-docker-rpi

docker run --rm -it --net host -v $(pwd)/dasher-config:/root/dasher-docker/config --name dasher-docker-rpi r11lein/dasher-docker-rpi script/find_button

docker build -t r11lein/dasher-docker-rpi ../dasher-docker-rpi/

docker run --rm -it --net host -v $(pwd)/dasher-config:/root/dasher-docker/config --name dasher-docker-rpi r11lein/dasher-docker-rpi

If you build from Dockerfile just ignore the node-gyp errors.

# Dasher!!

Dasher is a simple way to bridge your Amazon Dash buttons to HTTP services.

Do you have a Home Automation service set up like [Home Assistant](https://home-assistant.io), [openHab](http://www.openhab.org), or
maybe a SmartThings hub? Using Dasher, you can easily command them to do
something whenever your Dash button is pressed.

This of course goes for anything you can reach via HTTP. That includes IFTTT by
way of the Maker channel :metal:

## How it works

It's pretty simple. Press a button and an HTTP request is made. That's it.

You configure your Dash button(s) via `config/config.json`. You add its network
address, a url, an http method, and optionally a content body and headers.

When Dasher starts, it will listen for your button being pressed. Once it sees
it, it will then make the HTTP request that you defined for it in your config.

## Configuration

You define your buttons via the `config/config.json` file. It's a simple JSON
file that holds an array of buttons.

Here's an example.

```json
{
  "buttons": [
    {
      "name": "Notify",
      "address": "43:02:dc:b2:ab:23",
      "interface": "en0",
      "url": "https://maker.ifttt.com/trigger/Notify/with/key/5212ssx2k23k2k",
      "method": "POST",
      "json": true,
      "body": {
        "value1": "any value",
        "value2": "another value",
        "value3": "wow, even more value"
      }
    },
    {
      "name": "Party Time",
      "address": "d8:02:dc:98:63:49",
      "url": "http://192.168.1.55:8123/api/services/scene/turn_on",
      "method": "POST",
      "headers": { "authorization": "your_password" },
      "json": true,
      "body": { "entity_id": "scene.party_time" }
    },
    {
      "name": "Start Cooking Playlist",
      "address": "66:a0:dc:98:d2:63",
      "url": "http://192.168.1.55:8181/playlists/cooking/play",
      "method": "PUT"
    }
  ]
}
```

Buttons take up to 7 options.

- `name` - Optionally give the button action a name.
- `address` - The MAC address of the button.
- `interface` - Optionally listen for the button on a specific network interface. (`enX` on OS X and `ethX` on Linux)
- `url` - The URL that will be requested.
- `method` - The HTTP method of the request.
- `headers` - Optional headers to use in the request.
- `json` - Optionally declare the content body as being JSON in the request.
- `body` - Optionally provide a content-body that will be sent with the request.

Setting and using these values should be enough to cover almost every kind of
HTTP request you need to make.

You can find more examples in the [example config](/config/config.example.json).

## Setup

You'll want to set up your Dash buttons as well as Dasher.

### Dash button

Setting up your Dash button is as simple as following the instructions provided
by Amazon **EXCEPT FOR THE LAST STEP**. Just follow the instructions to set it
up in their mobile app. When you get to the step where it asks you to pick which
product you want to map it to, just quit the setup process.

The button will be set up and available on your network.

#### Find Dash Button

Once your Dash button is set up and on your network, you need to determine its
MAC address. Run this:

    script/find_button

You will be prompted for your password, and then it will listen for your Dash
button. Click your button and look for the MAC address reported. Once you have
its MAC address you will be able to configure it in Dasher.

### Dasher app

Then create a `config.json` in `/root/docker/config` to set up your Dash buttons. Use the
example to help you.
