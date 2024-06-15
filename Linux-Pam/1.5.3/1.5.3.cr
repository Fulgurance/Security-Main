class Target < ISM::Software

    def prepare
        super

        fileDeleteLine("#{buildDirectoryPath}modules/pam_namespace/Makefile.am",42)

        runAutoreconfCommand(path: buildDirectoryPath)
    end

    def configure
        super

        configureSource(arguments:  "--prefix=/usr                          \
                                    --sbindir=/usr/sbin                     \
                                    --sysconfdir=/etc                       \
                                    --libdir=/usr/lib                       \
                                    --enable-securedir=/usr/lib/security    \
                                    --docdir=/usr/share/doc/Linux-PAM-1.5.3",
                        path:       buildDirectoryPath)
    end

    def build
        super

        makeSource(path: buildDirectoryPath)
    end
    
    def prepareInstallation
        super

        makeSource( arguments:  "DESTDIR=#{builtSoftwareDirectoryPath}/#{Ism.settings.rootPath} install",
                    path:       buildDirectoryPath)

        makeDirectory("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d")

        if !softwareIsInstalled("Linux-Pam")
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

        runChmodCommand("04755 /usr/sbin/unix_chkpwd")
    end

end
