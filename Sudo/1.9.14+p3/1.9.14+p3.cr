class Target < ISM::Software

    def configure
        super

        configureSource([   "--prefix=/usr",
                            "--libexecdir=/usr/lib",
                            "--with-secure-path",
                            "--with-all-insults",
                            "--with-env-editor",
                            option("Linux-Pam") ? "--with-pam" : "--without-pam",
                            "--docdir=/usr/share/doc/sudo-1.9.14p3",
                            "--with-passprompt=\"[sudo] password for %p: \""],
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
            makeDirectory("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d")

            sudoData = <<-CODE
            auth      include     system-auth
            account   include     system-account
            session   required    pam_env.so
            session   include     system-session
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d/sudo",sudoData)
        end

        makeDirectory("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/sudoers.d")

        qtData = <<-CODE
        Defaults env_keep += QT5DIR
        Defaults env_keep += QT_PLUGIN_PATH
        Defaults env_keep += QML2_IMPORT_PATH
        CODE
        fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/sudoers.d/qt",qtData)

        makeDirectory("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/sudoers.d")

        kdeData = <<-CODE
        Defaults env_keep += KF5_PREFIX
        CODE
        fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/sudoers.d/kde",kdeData)
    end

end
