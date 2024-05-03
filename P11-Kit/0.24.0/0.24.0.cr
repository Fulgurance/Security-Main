class Target < ISM::Software
    
    def prepare
        @buildDirectory = true
        @buildDirectoryNames["MainBuild"] = "p11-build"
        super
        fileDeleteLine("#{mainWorkDirectoryPath(false)}trust/trust-extract-compat",20)
        fileDeleteLine("#{mainWorkDirectoryPath(false)}trust/trust-extract-compat",31)

        data = <<-CODE
        # Copy existing anchor modifications to /etc/ssl/local
        /usr/libexec/make-ca/copy-trust-modifications

        # Generate a new trust store
        /usr/sbin/make-ca -f -g
        CODE
        fileAppendData("#{mainWorkDirectoryPath(false)}trust/trust-extract-compat",data)
    end

    def configure
        super
        runMesonCommand([   "setup",
                            "--reconfigure",
                            "--prefix=/usr",
                            "--buildtype=release",
                            "-Dtrust_paths=/etc/pki/anchors"],
                            buildDirectoryPath)
    end

    def build
        super
        runNinjaCommand(Array(String).new,buildDirectoryPath)
    end
    
    def prepareInstallation
        super
        runNinjaCommand(["install"],buildDirectoryPath,{"DESTDIR" => "#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}"})
    end

    def install
        super
        makeLink("/usr/libexec/p11-kit/trust-extract-compat","#{Ism.settings.rootPath}usr/bin/update-ca-certificates",:symbolicLinkByOverwrite)
        makeLink("./pkcs11/p11-kit-trust.so","#{Ism.settings.rootPath}usr/lib/libnssckbi.so",:symbolicLinkByOverwrite)
    end

end
