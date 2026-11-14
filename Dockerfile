FROM node:26.13.1-alpine@sha256:6bd9ab43c0ec0190ca7b2d193906cb8b7edf6e7f4afa43ddeccd6452710bffb5

RUN apk add --update --no-cache \
  git \
  jq
WORKDIR "/home/node"
USER node
COPY --chown=node:node package.json package-lock.json .npmrc ./
RUN npm ci --omit=dev && mkdir -p .wiki
VOLUME "/home/node/.wiki"
EXPOSE 3000
ENV PATH="/home/node/node_modules/.bin:${PATH}"
CMD ["wiki", "--farm", "--security_type=friends"]
