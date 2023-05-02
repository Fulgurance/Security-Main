class Target < ISM::Software

    def configure
        super

        configureSource([   "--prefix=/usr",
                            "--libexecdir=/usr/lib",
                            "--with-secure-path",
                            "--with-all-insults",
                            "--with-env-editor",
                            option("Linux-Pam") ? "--with-pam" : "--without-pam",
                            "--docdir=/usr/share/doc/sudo-1.9.7p2",
                            "--with-passprompt=[sudo] password for %p: "],
                            buildDirectoryPath)
    end

    def build
        super

        makeSource(path: buildDirectoryPath)
    end
    
    def prepareInstallation
        super

        makeSource(["DESTDIR=#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}","install"],buildDirectoryPath)

        if option("Linux-Pam")
            makeDirectory("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}etc/pam.d")

            sudoData = <<-CODE
            auth      include     system-auth
            account   include     system-account
            session   required    pam_env.so
            session   include     system-session
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}etc/pam.d/sudo",sudoData)
        end

        if softwareIsInstalled("Qt")
            makeDirectory("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}etc/sudoers.d")

            sudoData = <<-CODE
            Defaults env_keep += QT5DIR
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}etc/sudoers.d/qt",sudoData)
        end
    end

    def install
        super

        makeLink("libsudo_util.so.0.0.0","#{Ism.settings.rootPath}usr/lib/sudo/libsudo_util.so.0",:symbolicLinkByOverwrite)
    end

end
