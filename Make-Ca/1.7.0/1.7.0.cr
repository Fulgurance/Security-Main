class Target < ISM::Software
    
    def prepareInstallation
        super
        makeSource([Ism.settings.makeOptions,"DESTDIR=#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}","install"],buildDirectoryPath)
        if Ism.softwareIsInstalled?(@information)
            runMakeCaCommand(["-g"])
        end
    end

    def install
        super
        makeDirectory("#{Ism.settings.rootPath}etc/ssl/local")
        setPermissions("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/ssl/local",0o755)
    end

end
