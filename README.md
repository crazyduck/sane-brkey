# sane-brkey

Docker container with SANE and brother scan key tool

## Debug commands

```
git fetch && git pull && docker compose up --force-recreate --build -d
docker exec -it sane-brkey-sane-1 /bin/bash -c "su -"
```
