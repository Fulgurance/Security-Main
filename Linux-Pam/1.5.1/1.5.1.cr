class Target < ISM::Software

    def prepare
        super

        fileDeleteLine("#{buildDirectoryPath(false)}modules/pam_namespace/Makefile.am",38)
        runAutoreconfCommand([] of String,buildDirectoryPath)
    end

    def configure
        super

        configureSource([   "--prefix=/usr",
                            "--sysconfdir=/etc",
                            "--libdir=/usr/lib",
                            "--enable-securedir=/usr/lib/security",
                            "--docdir=/usr/share/doc/Linux-PAM-1.5.1"],
                            buildDirectoryPath)
    end

    def build
        super

        makeSource([Ism.settings.makeOptions],buildDirectoryPath)
    end
    
    def prepareInstallation
        super

        makeSource([Ism.settings.makeOptions,"DESTDIR=#{builtSoftwareDirectoryPath}/#{Ism.settings.rootPath}","install"],buildDirectoryPath)

        makeDirectory("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d")

        if !Ism.softwareIsInstalled(@information)
            systemAccountData = <<-CODE
            account   required    pam_unix.so
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d/system-account",systemAccountData)

            systemAuthData = <<-CODE
            auth      required    pam_unix.so
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d/system-auth",systemAuthData)

            systemSessionData = <<-CODE
            session   required    pam_unix.so
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d/system-session",systemSessionData)

            systemPasswordData = <<-CODE
            password  required    pam_unix.so       sha512 shadow try_first_pass
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d/system-password",systemPasswordData)

            if option("Libpwquality")

                otherData = <<-CODE
                auth        required        pam_warn.so
                auth        required        pam_deny.so
                account     required        pam_warn.so
                account     required        pam_deny.so
                password    required        pam_warn.so
                password    required        pam_deny.so
                session     required        pam_warn.so
                session     required        pam_deny.so
                CODE
                fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d/other",otherData)

            end
        end
    end

    def install
        super

        setPermissions("#{Ism.settings.rootPath}usr/sbin/unix_chkpwd",0o4755)
    end

end