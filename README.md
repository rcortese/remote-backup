# Remote Backup Container

 Este reposit\u00f3rio fornece uma imagem Docker leve baseada em Alpine que executa um backup di\u00e1rio. Cada subpasta de `/data/source` \u00e9 compactada em um arquivo `tar.gz` datado e transferida via `rsync`. O destino pode manter um n\u00famero configur\u00e1vel de arquivos por subpasta, removendo os mais antigos quando `BACKUP_KEEP` for maior que zero. O padr\u00e3o \u00e9 `0`, indicando que n\u00e3o h\u00e1 limite e nada \u00e9 apagado.

## Estrutura do projeto

- **Dockerfile** - Constr\u00f3i a imagem com `rsync` e `openssh-client`, copia o script de backup e o entrypoint que configura o `cron`.
- **backup.sh** - Script que valida a conex\u00e7\u00e3o SSH, compacta cada subpasta e transfere os arquivos usando `rsync`,
  lendo as vari\u00e1veis definidas em `backup.conf`.
- **entrypoint.sh** - Configura o `cron` usando a vari\u00e1vel `CRON_SCHEDULE` e inicia o servi\u00e7o.
- **docker-compose.yml** - Facilita a cria\u00e7\u00e3o do container e o mapeamento de volumes.
- **backup.conf** - Arquivo de configura\u00e7\u00e3o com as vari\u00e1veis de ambiente utilizadas pelo `backup.sh`.

## Uso r\u00e1pido

1. Copie os dados que deseja sincronizar para `./data/source`.
2. Ajuste o arquivo `backup.conf` com o host, usu\u00e1rio e caminho remotos desejados.
3. Coloque uma chave privada SSH dentro da pasta `./.ssh` (por exemplo `id_rsa` ou `id_ed25519`) com acesso ao host de destino.
4. Construa e inicialize o container:

   ```bash
   docker compose up --build -d
   ```

O container executar\u00e1 diariamente o `backup.sh`, que compacta cada subpasta e envia os arquivos ao destino, registrando a sa\u00edda no console.

## Personaliza\u00e7\u00e3o

Edite o arquivo `backup.conf` para definir as vari\u00e1veis `REMOTE_HOST`, `REMOTE_PATH` e opcionalmente `REMOTE_USER`, al\u00e9m de `BACKUP_KEEP` caso deseje alterar a quantidade de arquivos preservados por subpasta. O valor padr\u00e3o \u00e9 `0`, indicando que n\u00e3o h\u00e1 limite. A vari\u00e1vel `REMOTE_USER` assume `root` quando n\u00e3o definida. Os valores do reposit\u00f3rio s\u00e3o apenas exemplos. O arquivo \u00e9 montado no container e lido automaticamente pelo `backup.sh` a cada execu\u00e7\u00e3o.

Tamb\u00e9m \u00e9 poss\u00edvel ajustar a frequ\u00eancia de execu\u00e7\u00e3o definindo a vari\u00e1vel de ambiente `CRON_SCHEDULE`. O padr\u00e3o \u00e9 `0 3 * * *`, que significa diariamente \u00e0s 3h da manh\u00e3. Essa vari\u00e1vel pode ser alterada no `docker-compose.yml` ou no momento de iniciar o container.

