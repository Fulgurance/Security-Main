class Target < ISM::Software
    
    def prepare
        @buildDirectory = true
        @buildDirectoryNames["MainBuild"] = "p11-build"
        super

        data = <<-CODE
        # Copy existing anchor modifications to /etc/ssl/local
        /usr/libexec/make-ca/copy-trust-modifications

        # Update trust stores
        /usr/sbin/make-ca -r
        CODE
        fileAppendData("#{mainWorkDirectoryPath}trust/trust-extract-compat",data)
    end

    def configure
        super

        runMesonCommand(arguments:  "setup                                  \
                                    --reconfigure                           \
                                    #{@buildDirectoryNames["MainBuild"]}    \
                                    --prefix=/usr                           \
                                    --buildtype=release                     \
                                    -Dtrust_paths=/etc/pki/anchors",
                        path:   mainWorkDirectoryPath)
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

        makeLink(   target: "/usr/libexec/p11-kit/trust-extract-compat",
                    path:   "#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}usr/bin/update-ca-certificates",
                    type:   :symbolicLinkByOverwrite)

        makeLink(   target: "./pkcs11/p11-kit-trust.so",
                    path:   "#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}usr/lib64/libnssckbi.so",
                    type:   :symbolicLinkByOverwrite)
    end

end
