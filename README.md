# Remote Backup Container

Este reposit\u00f3rio fornece uma imagem Docker leve baseada em Alpine que executa um backup di\u00e1rio via `rsync`.

O backup copia o conteudo de `/data/source` para um servidor remoto configurado pelo usuario usando a chave SSH do host.

## Estrutura do projeto

- **Dockerfile** - Constr\u00f3i a imagem com `rsync` e `openssh-client`, copia o script de backup e configura o `cron`.
- **backup.sh** - Script que valida a conex\u00e7\u00e3o SSH e executa o `rsync`,
  lendo as vari\u00e1veis definidas em `backup.conf`.
- **crontab** - Agenda a execu\u00e7\u00e3o di\u00e1ria \u00e0s 3h da manh\u00e3.
- **docker-compose.yml** - Facilita a cria\u00e7\u00e3o do container e o mapeamento de volumes.
- **backup.conf** - Arquivo de configura\u00e7\u00e3o com as vari\u00e1veis de ambiente utilizadas pelo `backup.sh`.

## Uso r\u00e1pido

1. Copie os dados que deseja sincronizar para `./data/source`.
2. Ajuste o arquivo `backup.conf` com o host e caminho remotos desejados.
3. Coloque uma chave privada SSH dentro da pasta `./.ssh` (por exemplo `id_rsa` ou `id_ed25519`) com acesso ao host de destino.
4. Construa e inicialize o container:

   ```bash
   docker compose up --build -d
   ```

O container executar\u00e1 diariamente o `backup.sh`, registrando a sa\u00edda no console.

## Personaliza\u00e7\u00e3o

Edite o arquivo `backup.conf` para definir as variaveis `REMOTE_HOST` e `REMOTE_PATH` conforme seu ambiente. Os valores do repositorio sao apenas exemplos. O arquivo e montado no container e lido automaticamente pelo `backup.sh` a cada execucao.

