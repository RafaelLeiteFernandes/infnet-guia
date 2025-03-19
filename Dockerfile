# Etapa 1: Build
FROM node:18-alpine AS builder
WORKDIR /app

# Copia apenas os arquivos de dependências para aproveitar o cache
COPY package*.json ./

# Instala as dependências com o flag --legacy-peer-deps para ignorar conflitos
RUN npm install --legacy-peer-deps

# Copia o restante do código
COPY . .

# Garante que os binários em node_modules/.bin tenham permissão de execução
RUN chmod -R 755 node_modules/.bin

# Executa o build da aplicação (gera a pasta .next)
RUN npm run build

# Etapa 2: Produção
FROM node:18-alpine AS runner
WORKDIR /app

# Define as variáveis de ambiente
ENV NODE_ENV=production
ENV PORT=3000

# Copia os arquivos essenciais do estágio de build
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
# Se houver outros arquivos necessários (como next.config.js), copie-os também:
# COPY --from=builder /app/next.config.js ./

# Instala somente as dependências de produção com o flag --legacy-peer-deps
RUN npm install --only=production --legacy-peer-deps

# Expõe a porta da aplicação
EXPOSE 3000

# Comando para iniciar a aplicação
CMD ["npm", "start"]