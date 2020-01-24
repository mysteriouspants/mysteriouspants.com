# requires rsync, see https://chocolatey.org/packages/rsync

$RemoteUser="xpm"
$RemoteHost="mysteriouspants.com"
$RemotePath="/var/www/www.mysteriouspants.com"

zola build

ssh ${RemoteUser}@${RemoteHost} sudo chown ${RemoteUser}:${RemoteUser} ${RemotePath}
rsync.exe -avz public/ ${RemoteUser}@${RemoteHost}:${RemotePath}/
ssh ${RemoteUser}@${RemoteHost} "find ${RemotePath} -type d -exec chmod 755 {} \;"
ssh ${RemoteUser}@${RemoteHost} "find ${RemotePath} -type f -exec chmod 644 {} \;"
