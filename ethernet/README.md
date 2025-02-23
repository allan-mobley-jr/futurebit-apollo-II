# Ethernet Issues

My Futurebit Apollo II Full Node came with a faulty Ethernet port out of the box. 

While Futurebit offered to fix it, I would have had to pay shipping to send it back and wait who knows how long before they fixed it and sent it back.

I had already waited over a month to get the device, so I was loath to do it, but I also did not want to rely on WiFi for my node and solo pool.

## Solution

I decided to try a USB Ethernet adapter instead, using the thrid USB port on back of the device. The other two are being used by Futurebit Apollo II Standards (a.k.a., miners).

It worked on reboot!

## The Saga Continues

The adapter worked initially but after a few hours my router showed my Futurebit Apollo II Full Node as being offline, and I was unable to reach my dashboard via a browser.

I disabled the internal Ethernet port as this was still trying to connect even though a cable was not plugged in.

I even set the Ethernet adapter as the default and assigned it the highest priority.

But alas, the same issue would reoccur after a few hours.

## Final Solution

It seems that there is perhaps a releasing issue between my router and my Futurebit Apollo II Full Node.

After trying various network configurations to no avail, I have decided to try a running a script that periodically checks the network connection and restarts the Ethernet adapter if the connection is down.

It remains to be seen if this works. 

Below are the steps to install the script and run it periodically:

### Step 1: Save and Prepare the Script

* Copy the contents from network_checker.sh in this repo
* Save it to a file, e.g., /usr/local/bin/network_checker.sh
* NOTE: Make sure to update the variables in the script to reflect your environment!
  
  ```bash
  sudo nano /usr/local/bin/network_checker.sh
  ```

* Paste the script contents, save (Ctrl+O, Enter), and exit (Ctrl+X)

* Make it Executable
  
  ```bash
  sudo chmod +x /usr/local/bin/network_checker.sh
  ```

* Test the Script
  
  ```bash
  # Run it manually to ensure it works
  sudo /usr/local/bin/network_checker.sh

  # Check the log file
  cat /var/log/network_checker.log
  ```

### Step 2: Schedule the Script with Cron

* Edit the Root Crontab
  
  ```bash
  sudo crontab -e
  ```

* Add the Cron Job
  
  ```bash
  # Run the script every 5 minutes
  */5 * * * * /usr/local/bin/network_checker.sh
  ```

* Save and exit (Ctrl+O, Enter, Ctrl+X)

* Handle Sudo Permissions (if needed)
* Since the script uses sudo, ensure it can run without a password prompt when executed via cron as root. Typically, root cron jobs don’t need this, but if you run it as a user, configure sudoers
  
  ```bash
  sudo visudo
  ```

* Add
  
  ```bash
  futurebit ALL=(ALL) NOPASSWD: /sbin/ip link set enx287bd2ced43f down, /sbin/ip link set enx287bd2ced43f up
  ```

* Replace `futurebit` with your username if not running as root and `enx287bd2ced43f` with your Ethernet adpater id

* Save and exit (Ctrl+O, Enter, Ctrl+X)

### Step 3: Monitor the Results

* Check the Log File
  
  ```bash
  cat /var/log/network_checker.log
  ```

* Look for entries like
  
  ```text
  2023-10-15 14:00:00 - Ping to 192.168.86.1 successful. No action needed.
  2023-10-15 14:05:00 - Ping to 192.168.86.1 failed. Restarting interface enx287bd2ced43f.
  2023-10-15 14:05:01 - Interface enx287bd2ced43f restarted.
  ```

### Step 4: Manage Log File Growth

* Create a Logrotate Configuration File
  
  ```bash
  sudo nano /etc/logrotate.d/network_checker
  ```

* Add the following content
  
  ```text
  /var/log/network_checker.log {
    daily
    rotate 7
    compress
    delaycompress
    maxsize 1M
    missingok
    notifempty
    copytruncate
  }
  ```

* Save and exit (Ctrl+O, Enter, Ctrl+X)

* Run logrotate manually to ensure it works
  
  ```bash
  sudo logrotate -f /etc/logrotate.d/network_checker
  ```

* Check the Log File
  
  ```bash
  cat /var/log/network_checker.log
  ```
