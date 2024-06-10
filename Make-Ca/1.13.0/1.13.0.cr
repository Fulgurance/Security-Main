class Target < ISM::Software
    
    def prepareInstallation
        super

        makeSource(["DESTDIR=#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}","install"],buildDirectoryPath)

        makeDirectory("#{builtSoftwareDirectoryPath}#{Ism.settings.rootPath}/etc/ssl/local")
    end

    def install
        super

        runChmodCommand(["0755","/etc/ssl/local"])

        softwareIsInstalled("Make-Ca") ? runMakeCaCommand(["-r"]) : runMakeCaCommand(["-g"])
    end

end
