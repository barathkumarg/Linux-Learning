# Content 

1. [Systemd](#systemd)


## Systemd

 - To start the particular process as in the background, auto-restart and stop on demand.

### Register as the systemd process
![](../media/Service_Management/systemd-1.png)

![](../media/Service_Management/systemd-2.png)

- systemctl daemon-reload : To reload the deamon and apply the new changes
- systemctl edit <filename> --full : To edit the service file and cannot start the process

### Systemd tools

- Systemd : creates, start, stop and disables the systemd registered process
- Journalctl : Queries the systemctl 

![](../media/Service_Management/systemd-3.png)

![](../media/Service_Management/systemd-4.png)

