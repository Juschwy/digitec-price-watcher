# [Digitec](https://digitec.ch) Price Watcher

## Description

A simple Price Watcher, that updates you via [ntfy](https://ntfy.sh), if new Prices are released or everytime the script is executed.

### Price Watcher v1

This script just "curls" the digitec website and sends you the prices over ntfy
I recommend running this script every day, in the morning, to get the price of the day

### Price Watcher v2

This scripts also "curls" the digitec website, but saves the price in a ``backup.yaml`` file. Only when the price is different, you will get a message with the changed prices.
I recommend running this script every hour, to check for new prices

## Usage

1. Place your desired script, on a linux machine
2. Replace the ``<your-topic-name>`` with your ntfy topic name in the script
3. Create a ``links.txt`` file with the digitec links, each on one line
4. Create a cronjob to run the script when you want ([help](https://en.wikipedia.org/wiki/Cron))
   1. Recommondation for v1:
      ````text
      1 8 * * * <path-to-script>
      ````
   2. Recommondation for v2:
      ````text
      1 * * * * <path-to-script>
      ````