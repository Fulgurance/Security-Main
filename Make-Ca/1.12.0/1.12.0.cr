class Target < ISM::Software
    
    def prepareInstallation
        super

        makeSource(["DESTDIR=#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}","install"],buildDirectoryPath)
    end

    def prepareInstallation
        super

        makeDirectory("#{builtSoftwareDirectoryPath(false)}#{Ism.settings.rootPath}/etc/ssl/local")
    end

    def install
        super

        setPermissions("#{Ism.settings.rootPath}etc/ssl/local",0o755)
        softwareIsInstalled("Make-Ca") ? runMakeCaCommand(["-r"]) : runMakeCaCommand(["-g"])
    end

end
