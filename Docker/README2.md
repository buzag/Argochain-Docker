```
docker run -d --name argochain-validator \
  -p 30333:30333 \
  -p 9944:9944 \
  -v ${HOME}/argochain-data:/argochain \
  -e NODE_NAME=${NODE_NAME} \
  --restart unless-stopped <dockerhubuser>/argochain-validator
  ```