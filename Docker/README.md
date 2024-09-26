# Run Argochain validator with Docker

Make sure, ***docker is installed***.

Change `NODE_NAME=mynodename` and run

```
docker stop argochain-validator && docker rm argochain-validator && docker run -d --pull always --name argochain-validator -p 30333:30333 -p 9944:9944 -v ${HOME}/argochain-data:/argochain -e NODE_NAME=mynodename --restart unless-stopped buzag/argochain-validator
```

If you restart the host, the service will come up automatically.

If you re-run this line, it stops the service and re-pulls the latest container version.

It creates a folder `$HOME/argochain-data` and will sync THE ENTIRE BLOCKCHAIN. The sync process ***can take hours***!

You can view logs and check the progress here:

```
docker logs -f --tail=100 argochain-validator
```

# Get your session key
Your session key is here, it takes a few seconds until it appears:

```
cat $HOME/argochain-data/.session_key
```

Use it here: https://explorer.argoscan.net/#/staking/actions

Based on this guieline: https://devolved-ai.gitbook.io/argochain-validator-guide 

---

# Maintenance
## Rotate keys
If you would like to **rotate the keys**, delete the sesion key and restart.

```
sudo rm $HOME/argochain-data/.session_key && docker restart argochain-validator
```

This triggers the execution of rotate_keys.sh inside the container and generates new session_key. Don't forget to re-add it here: https://explorer.argoscan.net/#/staking/actions under "Change session keys".

## Automatic updates
For automatic updates watchtower is recommended:

```
docker run -d --name watchtower -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --cleanup
```