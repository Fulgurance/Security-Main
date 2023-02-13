class Target < ISM::Software
    
    def prepareInstallation
        super
        makeSource([Ism.settings.makeOptions,"DESTDIR=#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}","install"],buildDirectoryPath)
        runMakeCaCommand(["-g"])
    end

    def install
        super
        setPermissions("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}etc/ssl/local",0o755)
    end

end
