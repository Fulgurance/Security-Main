class Target < ISM::Software
    
    def prepareInstallation
        super
        makeSource([Ism.settings.makeOptions,"DESTDIR=#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}","install"],buildDirectoryPath)
    end

    def install
        super
        makeDirectory("#{Ism.settings.rootPath}etc/ssl/local")
        setPermissions("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/ssl/local",0o755)
        Ism.softwareIsInstalled(@information) ? runMakeCaCommand(["-r"]) : runMakeCaCommand(["-g"])
    end

end
