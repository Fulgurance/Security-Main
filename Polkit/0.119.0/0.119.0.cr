class Target < ISM::Software

    def prepare
        super

        runAutoreconfCommand(["-fv"],buildDirectoryPath)
    end

    def configure
        super

        configureSource([   "--prefix=/usr",
                            "--sysconfdir=/etc",
                            "--localstatedir=/var",
                            "--disable-static",
                            "--with-os-type=#{Ism.settings.systemName}",
                            "--disable-libsystemd-login",
                            "--disable-man-pages",
                            "--enable-introspection=no"],
                            buildDirectoryPath)
    end

    def build
        super

        makeSource([Ism.settings.makeOptions],buildDirectoryPath)
    end
    
    def prepareInstallation
        super

        makeSource([Ism.settings.makeOptions,"DESTDIR=#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}","install"],buildDirectoryPath)

        if option("Linux-Pam")
            makeDirectory("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d")

            polkitData = <<-CODE
            auth     include        system-auth
            account  include        system-account
            password include        system-password
            session  include        system-session
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d/polkit-1",polkitData)
        end
    end

    def install
        super

        runGroupAddCommand(["-fg","27","polkitd"])
        runUserAddCommand(["-c","\"PolicyKit Daemon Owner\"","-d","/etc/polkit-1","-u","27","-g","polkitd","-s","/bin/false","polkitd"])
    end

end
