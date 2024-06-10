class Target < ISM::Software

    def prepare
        super

        fileReplaceText("#{buildDirectoryPath}/src/Makefile.in","groups$(EXEEXT) ","")
        replaceTextAllFilesRecursivelyNamed("#{buildDirectoryPath}/man","Makefile.in","groups.1 "," ")
        replaceTextAllFilesRecursivelyNamed("#{buildDirectoryPath}/man","Makefile.in","getspnam.3 "," ")
        replaceTextAllFilesRecursivelyNamed("#{buildDirectoryPath}/man","Makefile.in","passwd.5 "," ")
        fileReplaceText("#{buildDirectoryPath}/etc/login.defs","/var/spool/mail","/var/mail")
        fileReplaceText("#{buildDirectoryPath}/etc/login.defs","PATH=/sbin:/bin:/usr/sbin:/usr/bin","PATH=/usr/sbin:/usr/bin")
        fileReplaceText("#{buildDirectoryPath}/etc/login.defs","PATH=/bin:/usr/sbin","PATH=/usr/bin")
        fileReplaceText("#{buildDirectoryPath}/etc/login.defs","#ENCRYPT_METHOD DES","ENCRYPT_METHOD SHA512")

        makeDirectory("#{builtSoftwareDirectoryPath}/#{Ism.settings.rootPath}/usr/bin/")
        generateEmptyFile("#{builtSoftwareDirectoryPath}/#{Ism.settings.rootPath}/usr/bin/passwd")

        if !File.exists?("#{Ism.settings.rootPath}/usr/bin/passwd")
            generateEmptyFile("#{Ism.settings.rootPath}/usr/bin/passwd")
        end
    end

    def configure
        super

        configureSource([   "--sysconfdir=/etc",
                            "--with-group-name-max-length=32",
                            "--disable-static",
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
        makeDirectory("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}/etc/default")

        useraddData = <<-CODE
        GROUP=1000
        CREATE_MAIL_SPOOL=no
        CODE
        fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/default/useradd",useraddData)

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
                fileReplaceText("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/login.defs","##{loginOption}","#{loginOption}")
            end

            loginData = <<-CODE
            auth      optional    pam_faildelay.so  delay=3000000
            auth      requisite   pam_nologin.so
            auth      include     system-auth
            account   required    pam_access.so
            account   include     system-account
            session   required    pam_env.so
            session   required    pam_limits.so
            session   include     system-session
            password  include     system-password
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d/login",loginData)

            passwdData = <<-CODE
            password  include     system-password
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d/passwd",passwdData)

            suData = <<-CODE
            auth      sufficient  pam_rootok.so
            auth      include     system-auth
            auth      required    pam_wheel.so use_uid
            account   include     system-account
            session   required    pam_env.so
            session   include     system-session
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d/su",suData)

            chageData = <<-CODE
            auth      sufficient  pam_rootok.so
            auth      include     system-auth
            account   include     system-account
            session   include     system-session
            password  required    pam_permit.so
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d/chage",chageData)

            chfnData = <<-CODE
            auth      sufficient  pam_rootok.so
            auth      include     system-auth
            account   include     system-account
            session   include     system-session
            password  required    pam_permit.so
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d/chfn",chfnData)

            chgpasswdData = <<-CODE
            auth      sufficient  pam_rootok.so
            auth      include     system-auth
            account   include     system-account
            session   include     system-session
            password  required    pam_permit.so
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d/chgpasswd",chgpasswdData)

            chpasswdData = <<-CODE
            auth      sufficient  pam_rootok.so
            auth      include     system-auth
            account   include     system-account
            session   include     system-session
            password  required    pam_permit.so
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d/chpasswd",chpasswdData)

            chshData = <<-CODE
            auth      sufficient  pam_rootok.so
            auth      include     system-auth
            account   include     system-account
            session   include     system-session
            password  required    pam_permit.so
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d/chsh",chshData)

            groupaddData = <<-CODE
            auth      sufficient  pam_rootok.so
            auth      include     system-auth
            account   include     system-account
            session   include     system-session
            password  required    pam_permit.so
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d/groupadd",groupaddData)

            groupdelData = <<-CODE
            auth      sufficient  pam_rootok.so
            auth      include     system-auth
            account   include     system-account
            session   include     system-session
            password  required    pam_permit.so
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d/groupdel",groupdelData)

            groupmemsData = <<-CODE
            auth      sufficient  pam_rootok.so
            auth      include     system-auth
            account   include     system-account
            session   include     system-session
            password  required    pam_permit.so
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d/groupmems",groupmemsData)

            groupmodData = <<-CODE
            auth      sufficient  pam_rootok.so
            auth      include     system-auth
            account   include     system-account
            session   include     system-session
            password  required    pam_permit.so
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d/groupmod",groupmodData)

            newusersData = <<-CODE
            auth      sufficient  pam_rootok.so
            auth      include     system-auth
            account   include     system-account
            session   include     system-session
            password  required    pam_permit.so
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d/newusers",newusersData)

            useraddData = <<-CODE
            auth      sufficient  pam_rootok.so
            auth      include     system-auth
            account   include     system-account
            session   include     system-session
            password  required    pam_permit.so
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d/useradd",useraddData)

            userdelData = <<-CODE
            auth      sufficient  pam_rootok.so
            auth      include     system-auth
            account   include     system-account
            session   include     system-session
            password  required    pam_permit.so
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d/userdel",userdelData)

            usermodData = <<-CODE
            auth      sufficient  pam_rootok.so
            auth      include     system-auth
            account   include     system-account
            session   include     system-session
            password  required    pam_permit.so
            CODE
            fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/pam.d/usermod",usermodData)
        else
            loginDefsOptions.each do |loginOption|
                fileReplaceText("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/login.defs","#{loginOption}","##{loginOption}")
            end
        end
    end

    def install
        super

        runPwconvCommand
        runGrpconvCommand


        runChmodCommand(["0644","/etc/login.defs"])

        runUserAddCommand(["-D","--gid","999"])

        if option("Linux-Pam")
            if File.exists?("#{Ism.settings.rootPath}etc/login.access")
                moveFile("#{Ism.settings.rootPath}etc/login.access","#{Ism.settings.rootPath}etc/login.access.NOUSE")
            end
            if File.exists?("#{Ism.settings.rootPath}etc/limits")
                moveFile("#{Ism.settings.rootPath}etc/limits","#{Ism.settings.rootPath}etc/limits.NOUSE")
            end
        else
            if File.exists?("#{Ism.settings.rootPath}etc/login.access.NOUSE")
                moveFile("#{Ism.settings.rootPath}etc/login.access.NOUSE","#{Ism.settings.rootPath}etc/login.access")
            end
            if File.exists?("#{Ism.settings.rootPath}etc/limits.NOUSE")
                moveFile("#{Ism.settings.rootPath}etc/limits.NOUSE","#{Ism.settings.rootPath}etc/limits")
            end
        end
    end

end
