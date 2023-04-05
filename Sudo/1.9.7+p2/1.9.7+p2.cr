class Target < ISM::Software

    def configure
        super

        configureSource([   "--prefix=/usr",
                            "--libexecdir=/usr/lib",
                            "--with-secure-path",
                            "--with-all-insults",
                            "--with-env-editor",
                            "--docdir=/usr/share/doc/sudo-1.9.7p2",
                            "--with-passprompt=[sudo] password for %p: "],
                            buildDirectoryPath)
    end

    def build
        super

        makeSource([Ism.settings.makeOptions],buildDirectoryPath)
    end
    
    def prepareInstallation
        super

        makeSource([Ism.settings.makeOptions,"DESTDIR=#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}","install"],buildDirectoryPath)

        if Dir.exists?("#{Ism.settings.rootPath}etc/pam.d")
            makeDirectory("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d")

            sudoData = <<-CODE
            auth      include     system-auth
            account   include     system-account
            session   required    pam_env.so
            session   include     system-session
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d/sudo",sudoData)
        end
    end

    def install
        super

        makeLink("libsudo_util.so.0.0.0","#{Ism.settings.rootPath}usr/lib/sudo/libsudo_util.so.0",:symbolicLinkByOverwrite)
    end

end
