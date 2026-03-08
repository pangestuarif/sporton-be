# Stage 1: Build
FROM node:22-alpine AS builder

WORKDIR /app

# Salin file pnpm-lock untuk instalasi dependencies
COPY package.json pnpm-lock.yaml ./

# Install pnpm dan semua dependencies (termasuk devDependencies untuk build)
RUN npm install -g pnpm && pnpm install

COPY . .

# Melakukan build (transpile ke JavaScript di folder dist)
RUN pnpm build

# Stage 2: Production
FROM node:22-alpine

WORKDIR /app

# Salin hanya file yang diperlukan untuk runtime
COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm install --prod

# Ambil hasil build dan folder migrations dari stage builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/migrations ./migrations

# --- PERBAIKAN PORT ---
# Sesuaikan dengan Port 8080 di Security Groups Terraform
EXPOSE 8080
ENV PORT 8080

# Pastikan aplikasi mendengarkan trafik dari luar container
ENV HOSTNAME "0.0.0.0"

CMD ["node", "dist/server.js"]
