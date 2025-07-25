# Remote Backup Container

Este reposit\u00f3rio fornece uma imagem Docker leve baseada em Alpine que executa um backup di\u00e1rio via `rsync`.

O backup copia o conte\u00fado de `/data/source` para o servidor remoto `10.18.19.2` usando a chave SSH do host.

## Estrutura do projeto

- **Dockerfile** - Constr\u00f3i a imagem com `rsync` e `openssh-client`, copia o script de backup e configura o `cron`.
- **backup.sh** - Script que valida a conex\u00e7\u00e3o SSH e executa o `rsync`.
- **crontab** - Agenda a execu\u00e7\u00e3o di\u00e1ria \u00e0s 3h da manh\u00e3.
- **docker-compose.yml** - Facilita a cria\u00e7\u00e3o do container e o mapeamento de volumes.

## Uso r\u00e1pido

1. Copie os dados que deseja sincronizar para `./data/source`.
2. Certifique-se de possuir uma chave SSH em `~/.ssh/id_ed25519` com acesso ao host de destino.
3. Construa e inicialize o container:

   ```bash
   docker compose up --build -d
   ```

O container executar\u00e1 diariamente o `backup.sh`, registrando a sa\u00edda no console.

## Personaliza\u00e7\u00e3o

Ajuste as vari\u00e1veis `REMOTE_HOST` e `REMOTE_PATH` no `backup.sh` conforme o destino desejado.

