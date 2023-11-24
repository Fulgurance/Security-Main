class Target < ISM::Software
    
    def prepare
        @buildDirectory = true
        @buildDirectoryName = "p11-build"
        super

        fileReplaceTextAtLineNumber("#{mainWorkDirectoryPath(false)}/p11-kit/modules.c","if (gi) {","if (gi) && gi != C_GetInterface {",386)

        fileDeleteLine("#{mainWorkDirectoryPath(false)}trust/trust-extract-compat",20)
        fileDeleteLine("#{mainWorkDirectoryPath(false)}trust/trust-extract-compat",31)

        data = <<-CODE
        # Copy existing anchor modifications to /etc/ssl/local
        /usr/libexec/make-ca/copy-trust-modifications

        # Update trust stores
        /usr/sbin/make-ca -r
        CODE
        fileAppendData("#{mainWorkDirectoryPath(false)}trust/trust-extract-compat",data)

        runMesonCommand(["setup",@buildDirectoryName],mainWorkDirectoryPath)
    end

    def configure
        super

        runMesonCommand([   "configure",
                            @buildDirectoryName,
                            "--prefix=/usr",
                            "--buildtype=release",
                            "-Dtrust_paths=/etc/pki/anchors"],
                            mainWorkDirectoryPath)
    end

    def build
        super

        runNinjaCommand(path: buildDirectoryPath)
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
