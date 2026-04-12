# Dynamic DNS update script
### File structure

```
client
|
\___ update_my_dyndns.sh

server
|
\___ create_dyndns_database.sql
 \__ update_dns.sh
  \_ update_dns@.service
```

### Client files
* `client/update_my_dyndns.sh`

This file should be used by the Dynamic DNS client (user/s) to push their IP Address to the database.
> [!Caution]
> If clients are trusted, we provide them ssh access and sudo rights to execute the systemctl command.
Otherwise, the `ssh` line must me modified and a different approach should be configured.

### Server files
* `server/create_dyndns_database.sql`

Initial database which must be created in order to store Dynamic DNS data.
Use (replace mariadb with mysql, as needed):  
    mariadb -u username -p database_name < server/create_dyndns_database.sql

* `update_dns.sh`

The Update DNS script should reside on the Dynamic DNS server itself, in a location accessible to root user.
> [!Important]
> Make sure you do `chmod 0755 update_dns.sh`.
Current version of the script is configured to use `docker` and `db` as container name for the `MariaDB` database. Future updates will be configurable. Until then, if you do not use `docker`, you may remove the `docker exec -t db ` command and adapt `mariadb` to include the full path (if not already present in `$PATH`).

* `update_dns@.service`

This `systemd` unit is used to trigger the script by passing the parameter sent by the client.  
The location must be `/etc/systemd/system/update_dns@.service` and the parameter format __MUST__ be:

    DYNDNSHOST_IP.ADD.RE.SS  
    For example:  
      examplehost_192.160.0.2

> [!NOTE]
> Current version doesn't perform synthax check, but if you only include `examplehost1`, the IP Address will default to `127.0.0.1`.
