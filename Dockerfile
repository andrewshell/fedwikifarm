FROM node:26.12.0-alpine@sha256:6f08a523443ddedf52941874c203475b0ad503e859ad70cb26ab8be9a517dbd5

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
