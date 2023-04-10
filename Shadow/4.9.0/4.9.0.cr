class Target < ISM::Software

    def prepare
        super

        fileReplaceText("#{buildDirectoryPath(false)}/src/Makefile.in","groups$(EXEEXT) ","")
        replaceTextAllFilesRecursivelyNamed("#{buildDirectoryPath(false)}/man","Makefile.in","groups.1 "," ")
        replaceTextAllFilesRecursivelyNamed("#{buildDirectoryPath(false)}/man","Makefile.in","getspnam.3 "," ")
        replaceTextAllFilesRecursivelyNamed("#{buildDirectoryPath(false)}/man","Makefile.in","passwd.5 "," ")
        fileReplaceText("#{buildDirectoryPath(false)}/etc/login.defs","/var/spool/mail","/var/mail")
        fileReplaceText("#{buildDirectoryPath(false)}/etc/login.defs","PATH=/sbin:/bin:/usr/sbin:/usr/bin","PATH=/usr/sbin:/usr/bin")
        fileReplaceText("#{buildDirectoryPath(false)}/etc/login.defs","PATH=/bin:/usr/sbin","PATH=/usr/bin")
        fileReplaceText("#{buildDirectoryPath(false)}/etc/login.defs","#ENCRYPT_METHOD DES","ENCRYPT_METHOD SHA512")
        fileReplaceText("#{buildDirectoryPath(false)}/libsubid/Makefile.am","$(LIBTCB)","$(LIBTCB) \\\n\t$(LIBPAM)")
        fileReplaceTextAtLineNumber("#{buildDirectoryPath(false)}/libmisc/salt.c","rounds","min_rounds",224)
        makeDirectory("#{builtSoftwareDirectoryPath(false)}/#{Ism.settings.rootPath}/usr/bin/")
        generateEmptyFile("#{builtSoftwareDirectoryPath(false)}/#{Ism.settings.rootPath}/usr/bin/passwd")

        if !File.exists?("#{Ism.settings.rootPath}/usr/bin/passwd")
            generateEmptyFile("#{Ism.settings.rootPath}/usr/bin/passwd")
        end

        runAutoreconfCommand(["-fiv"],buildDirectoryPath)
    end

    def configure
        super

        configureSource([   "--sysconfdir=/etc",
                            "--with-group-name-max-length=32",
                            option("Cracklib") ? "--with-libcrack" : "--without-libcrack",
                            option("Linux-Pam") ? "--with-libpam" : "--without-libpam"],
                            buildDirectoryPath)
    end

    def build
        super

        makeSource(path: buildDirectoryPath)
    end

    def prepareInstallation
        super

        makeSource(["exec_prefix=/usr","DESTDIR=#{builtSoftwareDirectoryPath}/#{Ism.settings.rootPath}","install"],buildDirectoryPath)
        makeSource(["-C","man","DESTDIR=#{builtSoftwareDirectoryPath}/#{Ism.settings.rootPath}","install-man"],buildDirectoryPath)
        makeDirectory("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}/etc/default")

        useraddData = <<-CODE
        GROUP=1000
        CREATE_MAIL_SPOOL=no
        CODE
        fileWriteData("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}etc/default/useradd",useraddData)

        loginDefsOptions = ["FAIL_DELAY",
                            "FAILLOG_ENAB",
                            "LASTLOG_ENAB",
                            "MAIL_CHECK_ENAB",
                            "OBSCURE_CHECKS_ENAB",
                            "PORTTIME_CHECKS_ENAB",
                            "QUOTAS_ENAB",
                            "CONSOLE MOTD_FILE",
                            "FTMP_FILE NOLOGINS_FILE",
                            "ENV_HZ PASS_MIN_LEN",
                            "SU_WHEEL_ONLY",
                            "CRACKLIB_DICTPATH",
                            "PASS_CHANGE_TRIES",
                            "PASS_ALWAYS_WARN",
                            "CHFN_AUTH ENCRYPT_METHOD",
                            "ENVIRON_FILE"]

        if option("Linux-Pam")
            loginDefsOptions.each do |loginOption|
                fileReplaceText("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}etc/login.defs","##{loginOption}","#{loginOption}")
            end
        else
            loginDefsOptions.each do |loginOption|
                fileReplaceText("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}etc/login.defs","#{loginOption}","##{loginOption}")
            end
        end
    end

    def install
        super

        runPwconvCommand
        runGrpconvCommand
        setPermissions("#{Ism.settings.rootPath}etc/login.defs",0o644)
    end

end
