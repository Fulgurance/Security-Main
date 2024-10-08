class Target < ISM::Software

    def prepare
        @buildDirectory = true
        super

        if option("Js")
            fileReplaceTextAtLineNumber(path:       "#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}/src/polkitbackend/polkitbackendjsauthority.cpp",
                                        text:       " { JS_Init",
                                        newText:    " { JS::DisableJitBackend(); JS_Init",
                                        lineNumber: 59)
        end
    end

    def configure
        super

        runMesonCommand(arguments:  "setup                                                                  \
                                    --reconfigure                                                           \
                                    #{@buildDirectoryNames["MainBuild"]}                                    \
                                    --prefix=/usr                                                           \
                                    --buildtype=release                                                     \
                                    -Dos_type=\"#{Ism.settings.systemTargetName}\"                          \
                                    #{option("Elogind") ? "-Dsession_tracking=libelogind" : ""}             \
                                    -Dauthfw=#{option("Linux-Pam") ? "pam" : "shadow"}                      \
                                    -Dintrospection=#{option("Gobject-Introspection") ? "true" : "false"}   \
                                    #{option("Js") ? "-Djs_engine=mozjs" : ""}                              \
                                    -Dman=false                                                             \
                                    -Dexamples=false                                                        \
                                    -Dgtk_doc=false                                                         \
                                    -Dtests=false",
                        path:       mainWorkDirectoryPath)
    end

    def build
        super

        runNinjaCommand(path: buildDirectoryPath)
    end

    def prepareInstallation
        super

        runNinjaCommand(arguments:      "install",
                        path:           buildDirectoryPath,
                        environment:    {"DESTDIR" => "#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}"})

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

        makeDirectory("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/polkit-1/rules.d/")

        adminData = <<-CODE
        polkit.addAdminRule(function(action, subject) {
            return ["unix-group:wheel"];
        });
        CODE
        fileWriteData("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/polkit-1/rules.d/10-admin.rules",adminData)
    end

end
