# auto-w2000
[![Archimede Solutions](https://archimedesolutions.it/themes/archimede_v_0/assets/dist/images/seo/twitter/twitterSeo.png)](https://archimedesolutions.it)

Automated hosts file updater with WinHelp2002 hosts file located at:

http://winhelp2002.mvps.org/hosts.htm

## Install

Create a scripts folder inside your root folder:

```bash
sudo mkdir -p /root/scripts
sudo chmod 700 -R /root/scripts
sudo cd /root/scripts
```
and inside:
```bash
sudo git clone https://github.com/ArchimedeSolutions/auto-w2000.git
sudo cd auto-w2000
sudo ./auto-w2000.sh

```


## TODOs
 - Automated systemd installation
 - Define log rotation on system