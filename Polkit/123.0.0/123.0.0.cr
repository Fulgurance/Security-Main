class Target < ISM::Software

    def prepare
        @buildDirectory = true
        super

        if option("Js")
            fileReplaceTextAtLineNumber("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}/src/polkitbackend/polkitbackendjsauthority.cpp"," { JS_Init"," { JS::DisableJitBackend(); JS_Init",59)
        end

        runMesonCommand(["setup",@buildDirectoryNames[:mainBuild]],mainWorkDirectoryPath)
    end

    def configure
        super

        runMesonCommand([   "configure",
                            @buildDirectoryNames[:mainBuild],
                            "--prefix=/usr",
                            "--buildtype=release",
                            "#{option("Elogind") ? "-Dsession_tracking=libelogind" : ""}",
                            "-Dauthfw=#{option("Linux-Pam") ? "pam" : "shadow"}",
                            "-Dintrospection=#{option("Gobject-Introspection") ? "true" : "false"}",
                            "#{option("Js") ? "-Djs_engine=mozjs" : ""}"
                            "-Dman=false",
                            "-Dexamples=false",
                            "-Dgtk_doc=false",
                            "-Dtests=false"],
                            mainWorkDirectoryPath)
    end

    def build
        super

        runNinjaCommand(path: buildDirectoryPath)
    end

    def prepareInstallation
        super

        runNinjaCommand(["install"],buildDirectoryPath,{"DESTDIR" => "#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}"})

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
