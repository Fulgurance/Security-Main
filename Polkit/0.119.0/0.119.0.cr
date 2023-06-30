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
                            "--enable-libelogind=#{option("Elogind") ? "yes" : "no"}",
                            "--with-authfw=#{option("Linux-Pam") ? "pam" : "shadow"}"],
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

            polkitData = <<-CODE
            auth     include        system-auth
            account  include        system-account
            password include        system-password
            session  include        system-session
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}etc/pam.d/polkit-1",polkitData)
        end

        makeDirectory("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}etc/polkit-1/rules.d/")

        adminData = <<-CODE
        polkit.addAdminRule(function(action, subject) {
            return ["unix-group:wheel"];
        });
        CODE
        fileWriteData("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}etc/polkit-1/rules.d/10-admin.rules",adminData)
    end

    def install
        super

        runGroupAddCommand(["-fg","27","polkitd"])
        runUserAddCommand(["-c","\"PolicyKit Daemon Owner\"","-d","/etc/polkit-1","-u","27","-g","polkitd","-s","/bin/false","polkitd"])
    end

end
