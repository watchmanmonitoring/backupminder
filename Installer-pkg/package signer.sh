# package signing

/usr/bin/productsign --sign "Developer ID Installer: Watchman Monitoring, Inc" /Users/Shared/Development/backupminder/Installer-pkg/Build/BackupMinder.pkg /Users/Shared/Development/backupminder/Installer-Signed/BackupMinder.pkg 

# get a signature for sparkle
md5 /Users/Shared/Development/backupminder/Installer-Signed/BackupMinder.pkg

open /Users/Shared/Development/backupminder/Installer-Signed/

