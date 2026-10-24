FROM node:24.22.1-alpine@sha256:06d7adf3e0ef61a13f1d28682726366f97a15aa1888c934d3ecec86c33918b53

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
