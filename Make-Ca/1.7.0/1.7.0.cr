class Target < ISM::Software
    
    def prepareInstallation
        super

        makeSource(["DESTDIR=#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}","install"],buildDirectoryPath)
    end

    def install
        super

        makeDirectory("#{Ism.settings.rootPath}etc/ssl/local")
        setPermissions("#{Ism.settings.rootPath}etc/ssl/local",0o755)
        softwareIsInstalled("Make-Ca") ? runMakeCaCommand(["-r"]) : runMakeCaCommand(["-g"])
    end

end
