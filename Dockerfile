FROM node:26.12.1-alpine@sha256:40cd011b55415bc894e45b02fdd5a5dfde056921b7d23a64c74f80497af48797

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
