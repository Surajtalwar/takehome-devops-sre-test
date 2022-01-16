FROM node:alpine AS BUILD_IMAGE

RUN apk add --no-cache

WORKDIR /app

COPY package*.json ./

RUN npm ci --only=production

FROM node:alpine AS BUILD_IMAGE_1

ENV NEXT_PUBLIC_APP_VERSION v1.2.2

WORKDIR /app

COPY . .

COPY --from=BUILD_IMAGE /app/node_modules ./node_modules

RUN npm run build

FROM node:alpine AS FINAL_BUILD

WORKDIR /app

RUN addgroup -S nonsudo && adduser -S nonroot -G nonsudo \
    && chown -R nonroot:nonsudo /app
    
COPY --from=BUILD_IMAGE_1 --chown=nonroot:nonsudo /app /app


USER nonroot

CMD ["npm", "run", "start"]