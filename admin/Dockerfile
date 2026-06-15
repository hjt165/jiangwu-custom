# ========== Stage 1: Build ==========
FROM node:20-alpine AS builder

WORKDIR /app

# 先复制 package.json，利用 Docker 缓存加速依赖安装
COPY package.json package-lock.json* pnpm-lock.yaml* yarn.lock* ./

# 安装依赖 (优先 pnpm > npm)
RUN if [ -f pnpm-lock.yaml ]; then \
        corepack enable && pnpm install --frozen-lockfile; \
    elif [ -f yarn.lock ]; then \
        yarn install --frozen-lockfile; \
    else \
        npm ci; \
    fi

# 复制源码并构建
COPY . .
RUN npm run build

# ========== Stage 2: Nginx ==========
FROM nginx:1.25-alpine

# 复制 Nginx 配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 从构建阶段复制 dist 产物
COPY --from=builder /app/dist /usr/share/nginx/html

# 暴露端口
EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]
