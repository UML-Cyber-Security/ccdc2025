# Networking Utility Programs and Scripts

## Counts
Program to analyze and aggregate the data contained in a pcap capture file. This is expected to be in a file named `received.pcap`.

Dependencies:
* [dpkt](https://dpkt.readthedocs.io/en/latest/): Packet creation and Parsing.
    ```sh
    pip install dpkt
    ```
* [pandas](https://pandas.pydata.org/docs/getting_started/install.html): Data Formatting (Normally more data analysis and manipulation... right?)
    ```
    pip install pandas
    ```

Run in the following manner:
```
python3 counts.py | more
```

This provides counts of recurring packets, hopefully allowing us to find useful patterns.
> [!NOTE]
> You can redirect the output to a file, or other programs.

## Persistent
Program to analyze and aggregate the data contained in a pcap capture file. This is expected to be in a file named `received.pcap`.

Dependencies:
* [dpkt](https://dpkt.readthedocs.io/en/latest/): Packet creation and Parsing.
    ```sh
    pip install dpkt
    ```

Run in the following manner:
```
python3 persistent.py | more
```
This provides a summery of persistent connections that have been captured sorted by length.
> [!NOTE]
> You can redirect the output to a file, or other programs.